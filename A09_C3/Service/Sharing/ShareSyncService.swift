//
//  ShareSyncService.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 27/07/26.
//

import CloudKit
import SwiftData

@MainActor
final class ShareSyncService {
    static let shared = ShareSyncService()
    private let manager = SharingManager.shared
    private init() {}
    
    private var syncingCareGroupIDs: Set<UUID> = []
    
    func performSync(for careGroup: CareGroupModel, context: ModelContext) async {
            guard !syncingCareGroupIDs.contains(careGroup.id) else {
                print("🟡 [SYNC] Sync untuk \(careGroup.id) sedang berjalan, dilewati")
                return
            }
            syncingCareGroupIDs.insert(careGroup.id)
            defer { syncingCareGroupIDs.remove(careGroup.id) }

            await pushUnsyncedRecords(for: careGroup, context: context)
            do {
                try await syncZoneChanges(careGroup: careGroup, context: context)
            } catch {
                print("🔴 [SYNC] syncZoneChanges gagal: \(error)")
            }
        }

    func push<T: CKSyncable>(_ model: T, isOwner: Bool) async throws {
        guard let record = model.toCKRecord() else { return }
        let database = isOwner ? manager.privateDatabase : manager.sharedDatabase

        let operation = CKModifyRecordsOperation(recordsToSave: [record])
        operation.savePolicy = .changedKeys   // BARU — paksa overwrite, hindari CAS conflict untuk update

        let savedRecord: CKRecord = try await withCheckedThrowingContinuation { cont in
            operation.perRecordSaveBlock = { _, result in
                switch result {
                case .success(let record): cont.resume(returning: record)
                case .failure(let error): cont.resume(throwing: error)
                }
            }
            database.add(operation)
        }
        model.ckRecordName = savedRecord.recordID.recordName
    }
    
    func acceptShare(metadata: CKShare.Metadata, context: ModelContext) async throws {
        let operation = CKAcceptSharesOperation(shareMetadatas: [metadata])
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            operation.acceptSharesResultBlock = { result in
                switch result {
                case .success: cont.resume()
                case .failure(let error): cont.resume(throwing: error)
                }
            }
            manager.container.add(operation)
        }

        let zoneID = metadata.share.recordID.zoneID
        let careGroup = CareGroupModel(patientName: metadata.share[CKShare.SystemFieldKey.title] as? String ?? "")
        careGroup.zoneName = zoneID.zoneName
        careGroup.zoneOwnerName = zoneID.ownerName
        careGroup.rootRecordName = metadata.rootRecordID.recordName
        careGroup.isOwner = false
        context.insert(careGroup)
        try? await SharingManager.shared.setupZoneSubscription(for: careGroup)
        try await syncZoneChanges(careGroup: careGroup, context: context)
    }
}

extension ShareSyncService {
    func migrateExistingRecords(to careGroup: CareGroupModel, context: ModelContext) async {
        careGroup.hasMigratedLegacyData = true   // dipertahankan sebagai penanda historis saja, tidak lagi jadi gate logic
        try? context.save()
        await pushUnsyncedRecords(for: careGroup, context: context)
    }
}

extension ShareSyncService {
    func pushUnsyncedRecords(for careGroup: CareGroupModel, context: ModelContext) async {
        let targetID = careGroup.id
        let isOwner = careGroup.isOwner   // BARU — dinamis, bukan hardcode
        print("🔵 [SYNC] pushUnsyncedRecords mulai, careGroup: \(targetID), isOwner: \(isOwner)")

        do {
            let orphanObat = try context.fetch(FetchDescriptor<Obat>(predicate: #Predicate { $0.careGroup == nil }))
            for obat in orphanObat { obat.careGroup = careGroup }
            let orphanPantauan = try context.fetch(FetchDescriptor<PantauanModel>(predicate: #Predicate { $0.careGroup == nil }))
            for pantauan in orphanPantauan { pantauan.careGroup = careGroup }
            let orphanKonsul = try context.fetch(FetchDescriptor<KonsulModel>(predicate: #Predicate { $0.careGroup == nil }))
            for konsul in orphanKonsul { konsul.careGroup = careGroup }
            if !orphanObat.isEmpty || !orphanPantauan.isEmpty || !orphanKonsul.isEmpty {
                try context.save()
            }

            let unsyncedObat = try context.fetch(FetchDescriptor<Obat>(predicate: #Predicate { $0.ckRecordName == nil }))
            for obat in unsyncedObat where obat.careGroup?.id == targetID {
                do { try await push(obat, isOwner: isOwner) }   // GANTI
                catch { print("🔴 [SYNC] Gagal push Obat \(obat.id): \(error)") }
            }

            let unsyncedPantauan = try context.fetch(FetchDescriptor<PantauanModel>(predicate: #Predicate { $0.ckRecordName == nil }))
            for pantauan in unsyncedPantauan where pantauan.careGroup?.id == targetID {
                do { try await push(pantauan, isOwner: isOwner) }   // GANTI
                catch { print("🔴 [SYNC] Gagal push Pantauan \(pantauan.id): \(error)") }
            }

            let unsyncedKonsul = try context.fetch(FetchDescriptor<KonsulModel>(predicate: #Predicate { $0.ckRecordName == nil }))
            for konsul in unsyncedKonsul where konsul.careGroup?.id == targetID {
                do { try await push(konsul, isOwner: isOwner) }   // GANTI
                catch { print("🔴 [SYNC] Gagal push Konsul \(konsul.id): \(error)") }
            }

            try context.save()
        } catch {
            print("🔴 [SYNC] Gagal mengambil data yang belum tersinkron: \(error)")
        }
    }
}

extension ShareSyncService {
    func syncZoneChanges(careGroup: CareGroupModel, context: ModelContext) async throws {
        let zoneID = CKRecordZone.ID(zoneName: careGroup.zoneName, ownerName: careGroup.zoneOwnerName)
        let database = careGroup.isOwner ? manager.privateDatabase : manager.sharedDatabase

        var previousToken: CKServerChangeToken?
        if let data = careGroup.changeTokenData {
            previousToken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data)
        }

        do {
            try await performZoneFetch(database: database, zoneID: zoneID, token: previousToken, careGroup: careGroup, context: context)
        } catch let error as CKError where error.code == .changeTokenExpired {
            print("🟡 [SYNC] Change token expired, reset dan sync ulang dari awal")
            careGroup.changeTokenData = nil
            try await performZoneFetch(database: database, zoneID: zoneID, token: nil, careGroup: careGroup, context: context)
        }
    }

    private func performZoneFetch(
        database: CKDatabase,
        zoneID: CKRecordZone.ID,
        token: CKServerChangeToken?,
        careGroup: CareGroupModel,
        context: ModelContext
    ) async throws {
        let result = try await database.recordZoneChanges(inZoneWith: zoneID, since: token)

        for (_, changeResult) in result.modificationResultsByID {
            if case .success(let modification) = changeResult {
                applyChange(record: modification.record, careGroup: careGroup, context: context)
            }
        }
        for deletion in result.deletions {
            applyDeletion(recordID: deletion.recordID, context: context)
        }
        if let tokenData = try? NSKeyedArchiver.archivedData(withRootObject: result.changeToken, requiringSecureCoding: true) {
            careGroup.changeTokenData = tokenData
        }
        try context.save()
    }

    private func applyChange(record: CKRecord, careGroup: CareGroupModel, context: ModelContext) {
        let recordName = record.recordID.recordName
        switch record.recordType {
        case Obat.ckRecordType:
            upsert(Obat.self, makeEmpty: { Obat() }, record: record, recordName: recordName, careGroup: careGroup, context: context)
        case PantauanModel.ckRecordType:
            upsert(PantauanModel.self, makeEmpty: { PantauanModel() }, record: record, recordName: recordName, careGroup: careGroup, context: context)
        case KonsulModel.ckRecordType:
            upsert(KonsulModel.self, makeEmpty: { KonsulModel() }, record: record, recordName: recordName, careGroup: careGroup, context: context)
        default:
            break
        }
    }

    private func upsert<T: PersistentModel & CKSyncable>(
        _ type: T.Type,
        makeEmpty: () -> T,
        record: CKRecord,
        recordName: String,
        careGroup: CareGroupModel,
        context: ModelContext
    ) {
        let descriptor = FetchDescriptor<T>(predicate: #Predicate { $0.ckRecordName == recordName })
        if let existing = try? context.fetch(descriptor).first {
            existing.apply(from: record)
        } else {
            let model = makeEmpty()
            model.apply(from: record)
            model.careGroup = careGroup
            context.insert(model)
        }
    }

    private func applyDeletion(recordID: CKRecord.ID, context: ModelContext) {
        let recordName = recordID.recordName
        if let obat = try? context.fetch(FetchDescriptor<Obat>(predicate: #Predicate { $0.ckRecordName == recordName })).first {
            context.delete(obat)
        }
        if let pantauan = try? context.fetch(FetchDescriptor<PantauanModel>(predicate: #Predicate { $0.ckRecordName == recordName })).first {
            context.delete(pantauan)
        }
        if let konsul = try? context.fetch(FetchDescriptor<KonsulModel>(predicate: #Predicate { $0.ckRecordName == recordName })).first {
            context.delete(konsul)
        }
    }
}

extension ShareSyncService {
    func deleteRemote<T: CKSyncable>(_ model: T, isOwner: Bool) async {
        guard let ckRecordName = model.ckRecordName else { return }   // belum pernah sync, tidak perlu hapus di server
        guard let careGroup = model.careGroup else { return }
        let zoneID = CKRecordZone.ID(zoneName: careGroup.zoneName, ownerName: careGroup.zoneOwnerName)
        let recordID = CKRecord.ID(recordName: ckRecordName, zoneID: zoneID)
        let database = isOwner ? manager.privateDatabase : manager.sharedDatabase

        do {
            _ = try await database.deleteRecord(withID: recordID)
        } catch {
            print("🔴 [SYNC] Gagal hapus record di CloudKit: \(error)")
        }
    }
}
