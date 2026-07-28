//
//  KonsulModel+CKSyncable.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 27/07/26.
//

import CloudKit

extension KonsulModel: CKSyncable {
    static var ckRecordType: String { "Konsultasi" }

    func populate(_ record: CKRecord) {
        record["namaDokter"] = namaDokter
        record["tanggalKonsultasi"] = tanggalKonsultasi
        record["content"] = content
        record["konsulCreatedAt"] = konsulCreatedAt
        record["kosulUpdatedAt"] = kosulUpdatedAt
    }

    func apply(from record: CKRecord) {
        namaDokter = record["namaDokter"] as? String ?? ""
        tanggalKonsultasi = record["tanggalKonsultasi"] as? Date ?? .now
        content = record["content"] as? String ?? ""
        konsulCreatedAt = record["konsulCreatedAt"] as? Date ?? .now
        kosulUpdatedAt = record["kosulUpdatedAt"] as? Date
        ckRecordName = record.recordID.recordName
    }
}
