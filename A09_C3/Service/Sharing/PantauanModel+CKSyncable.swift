//
//  PantauanModel+CKSyncable.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 27/07/26.
//

import CloudKit

extension PantauanModel: CKSyncable {
    static var ckRecordType: String { "Pantauan" }

    func populate(_ record: CKRecord) {
        record["pantauanDate"] = pantauanDate
        record["pantauanBody"] = pantauanBody
        record["pantauanCreatedAt"] = pantauanCreatedAt
        record["pantauanUpdatedAt"] = pantauanUpdatedAt
    }

    func apply(from record: CKRecord) {
        pantauanDate = record["pantauanDate"] as? Date ?? .now
        pantauanBody = record["pantauanBody"] as? String ?? ""
        pantauanCreatedAt = record["pantauanCreatedAt"] as? Date ?? .now
        pantauanUpdatedAt = record["pantauanUpdatedAt"] as? Date
        ckRecordName = record.recordID.recordName
    }
}
