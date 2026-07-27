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
    
    func push<T: CKSyncable>(_ model: T, isOwner: Bool) async throws {
        guard let record = model.toCKRecord() else { return }
        let database = isOwner ? manager.privateDatabase : manager.sharedDatabase
        let saved = try await database.save(record)
        model.ckRecordName = saved.recordID.recordName
    }
    
    func fetchAll<T: PersistentModel & CKSyncable>(
        _ type: T.Type,
        makeEmpty: () -> T,
        zoneID: CKRecordZone.ID,
        from database: CKDatabase,
        careGroup: CareGroupModel,
        context: ModelContext
    ) async throws {
        let query = CKQuery(recordType: T.ckRecordType, predicate: NSPredicate(value: true))
        let (results, _) = try await database.records(matching: query, inZoneWith: zoneID)
        
        for (_, result) in results {
            guard case .success(let record) = result else { continue }
            let model = makeEmpty()
            model.apply(from: record)
            model.careGroup = careGroup
            context.insert(model)
        }
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
        
        try await fetchAll(Obat.self, makeEmpty: { Obat() }, zoneID: zoneID, from: manager.sharedDatabase, careGroup: careGroup, context: context)
        try await fetchAll(PantauanModel.self, makeEmpty: { PantauanModel() }, zoneID: zoneID, from: manager.sharedDatabase, careGroup: careGroup, context: context)
        try await fetchAll(KonsulModel.self, makeEmpty: { KonsulModel() }, zoneID: zoneID, from: manager.sharedDatabase, careGroup: careGroup, context: context)
        
        try context.save()
    }
}


extension ShareSyncService {
    func migrateExistingRecords(to careGroup: CareGroupModel, context: ModelContext) async {
        if !careGroup.hasMigratedLegacyData {
            do {
                let legacyObat = try context.fetch(
                    FetchDescriptor<Obat>(predicate: #Predicate { $0.careGroup == nil })
                )
                let legacyPantauan = try context.fetch(
                    FetchDescriptor<PantauanModel>(predicate: #Predicate { $0.careGroup == nil })
                )
                let legacyKonsul = try context.fetch(
                    FetchDescriptor<KonsulModel>(predicate: #Predicate { $0.careGroup == nil })
                )

                for obat in legacyObat { obat.careGroup = careGroup }
                for pantauan in legacyPantauan { pantauan.careGroup = careGroup }
                for konsul in legacyKonsul { konsul.careGroup = careGroup }

                careGroup.hasMigratedLegacyData = true
                try context.save()
            } catch {
                print("Gagal mengambil data lama untuk migrasi: \(error)")
            }
        }
        await pushUnsyncedRecords(for: careGroup, context: context)
    }
}

extension ShareSyncService {
    func pushUnsyncedRecords(for careGroup: CareGroupModel, context: ModelContext) async {
        let targetID = careGroup.id

        do {
            let unsyncedObat = try context.fetch(
                FetchDescriptor<Obat>(predicate: #Predicate { $0.ckRecordName == nil })
            )
            for obat in unsyncedObat where obat.careGroup?.id == targetID {
                do { try await push(obat, isOwner: true) }
                catch { print("Gagal push Obat \(obat.id): \(error)") }
            }

            let unsyncedPantauan = try context.fetch(
                FetchDescriptor<PantauanModel>(predicate: #Predicate { $0.ckRecordName == nil })
            )
            for pantauan in unsyncedPantauan where pantauan.careGroup?.id == targetID {
                do { try await push(pantauan, isOwner: true) }
                catch { print("Gagal push Pantauan \(pantauan.id): \(error)") }
            }

            let unsyncedKonsul = try context.fetch(
                FetchDescriptor<KonsulModel>(predicate: #Predicate { $0.ckRecordName == nil })
            )
            for konsul in unsyncedKonsul where konsul.careGroup?.id == targetID {
                do { try await push(konsul, isOwner: true) }
                catch { print("Gagal push Konsul \(konsul.id): \(error)") }
            }

            try context.save()
        } catch {
            print("Gagal mengambil data yang belum tersinkron: \(error)")
        }
    }
}
extension ShareSyncService {
    
    func refreshSharedData(careGroup: CareGroupModel, context: ModelContext) async throws {
        let zoneID = CKRecordZone.ID(zoneName: careGroup.zoneName, ownerName: careGroup.zoneOwnerName)
        let database = careGroup.isOwner ? manager.privateDatabase : manager.sharedDatabase

        try await upsertAll(Obat.self, makeEmpty: { Obat() }, zoneID: zoneID, from: database, careGroup: careGroup, context: context)
        try await upsertAll(PantauanModel.self, makeEmpty: { PantauanModel() }, zoneID: zoneID, from: database, careGroup: careGroup, context: context)
        try await upsertAll(KonsulModel.self, makeEmpty: { KonsulModel() }, zoneID: zoneID, from: database, careGroup: careGroup, context: context)

        try context.save()
    }

    private func upsertAll<T: PersistentModel & CKSyncable>(
        _ type: T.Type,
        makeEmpty: () -> T,
        zoneID: CKRecordZone.ID,
        from database: CKDatabase,
        careGroup: CareGroupModel,
        context: ModelContext
    ) async throws {
        let query = CKQuery(recordType: T.ckRecordType, predicate: NSPredicate(value: true))
        let (results, _) = try await database.records(matching: query, inZoneWith: zoneID)

        for (recordID, result) in results {
            guard case .success(let record) = result else { continue }
            let recordName = recordID.recordName

            let descriptor = FetchDescriptor<T>(
                predicate: #Predicate { $0.ckRecordName == recordName }
            )
            if let existing = try context.fetch(descriptor).first {
                existing.apply(from: record)
            } else {
                let model = makeEmpty()
                model.apply(from: record)
                model.careGroup = careGroup
                context.insert(model)
            }
        }
    }
}
