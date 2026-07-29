//
//  SharingManager.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 27/07/26.
//

import CloudKit
import SwiftData

@MainActor
final class SharingManager {
    static let shared = SharingManager()
    
    let container = CKContainer(identifier: "iCloud.com.challenge3.A09-C3")
    var privateDatabase: CKDatabase { container.privateCloudDatabase }
    var sharedDatabase: CKDatabase { container.sharedCloudDatabase }
    
    private init() {}
    
    func createCareGroup(patientName: String, context: ModelContext) async throws -> CareGroupModel {
        let zoneID = CKRecordZone.ID(zoneName: "careGroup-\(UUID().uuidString)")
        let zone = CKRecordZone(zoneID: zoneID)
        _ = try await privateDatabase.save(zone)
        
        let rootID = CKRecord.ID(recordName: UUID().uuidString, zoneID: zoneID)
        let rootRecord = CKRecord(recordType: "PatientProfile", recordID: rootID)
        rootRecord["patientName"] = patientName
        _ = try await privateDatabase.save(rootRecord)
        
        let careGroup = CareGroupModel(patientName: patientName)
        careGroup.zoneName = zoneID.zoneName
        careGroup.zoneOwnerName = zoneID.ownerName
        careGroup.rootRecordName = rootID.recordName
        careGroup.isOwner = true
        context.insert(careGroup)
        try context.save()
        
        return careGroup
    }
    
    func createShare(for careGroup: CareGroupModel) async throws -> (CKShare, CKContainer) {
        let zoneID = CKRecordZone.ID(zoneName: careGroup.zoneName, ownerName: careGroup.zoneOwnerName)
        let rootID = CKRecord.ID(recordName: careGroup.rootRecordName, zoneID: zoneID)
        
        return try await createShareWithRetry(rootID: rootID, careGroup: careGroup, attemptsLeft: 3)
    }
    
    private func createShareWithRetry(
        rootID: CKRecord.ID,
        careGroup: CareGroupModel,
        attemptsLeft: Int
    ) async throws -> (CKShare, CKContainer) {
        let rootRecord = try await privateDatabase.record(for: rootID)
        
        let share = CKShare(rootRecord: rootRecord)
        share[CKShare.SystemFieldKey.title] = careGroup.patientName as CKRecordValue
        share.publicPermission = .readWrite
        
        let operation = CKModifyRecordsOperation(recordsToSave: [rootRecord, share])
        operation.savePolicy = .changedKeys
        
        do {
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                operation.modifyRecordsResultBlock = { result in
                    switch result {
                    case .success: cont.resume()
                    case .failure(let error): cont.resume(throwing: error)
                    }
                }
                privateDatabase.add(operation)
            }
            return (share, container)
        } catch let error as CKError where error.code == .serverRecordChanged && attemptsLeft > 0 {
            try await Task.sleep(nanoseconds: 500_000_000)
            return try await createShareWithRetry(rootID: rootID, careGroup: careGroup, attemptsLeft: attemptsLeft - 1)
        }
    }
}

extension SharingManager {
    func setupZoneSubscription(for careGroup: CareGroupModel) async throws {
        let zoneID = CKRecordZone.ID(zoneName: careGroup.zoneName, ownerName: careGroup.zoneOwnerName)
        let subscriptionID = "zone-changes-\(zoneID.zoneName)"
        
        let subscription = CKRecordZoneSubscription(zoneID: zoneID, subscriptionID: subscriptionID)
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true   // silent push, tidak muncul banner
        subscription.notificationInfo = notificationInfo
        
        let database = careGroup.isOwner ? privateDatabase : sharedDatabase
        _ = try await database.save(subscription)
    }
}
