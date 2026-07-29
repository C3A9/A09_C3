//
//  CKSyncable.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 27/07/26.
//

import CloudKit
import Foundation

protocol CKSyncable: AnyObject {
    static var ckRecordType: String { get }
    var id: UUID { get }
    var ckRecordName: String? { get set }
    var careGroup: CareGroupModel? { get set }

    func populate(_ record: CKRecord)
    func apply(from record: CKRecord)
}

extension CKSyncable {
    func toCKRecord() -> CKRecord? {
        guard let careGroup else { return nil }
        let zoneID = CKRecordZone.ID(zoneName: careGroup.zoneName, ownerName: careGroup.zoneOwnerName)
        let recordID = CKRecord.ID(recordName: ckRecordName ?? id.uuidString, zoneID: zoneID)
        let record = CKRecord(recordType: Self.ckRecordType, recordID: recordID)

        populate(record)

        let rootRecordID = CKRecord.ID(recordName: careGroup.rootRecordName, zoneID: zoneID)
        record.parent = CKRecord.Reference(recordID: rootRecordID, action: .none)

        return record
    }
}
