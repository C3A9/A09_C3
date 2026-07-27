//
//  ObatModel+CKSyncable.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 27/07/26.
//

import CloudKit

extension Obat: CKSyncable {
    static var ckRecordType: String { "Obat" }

    func populate(_ record: CKRecord) {
        record["nama"] = nama
        record["jenis"] = jenis.rawValue
        record["dosis"] = dosis
        record["frekuensi"] = frekuensi
        record["keterangan"] = keterangan.rawValue
        record["isKondisional"] = isKondisional
        record["kondisiDetail"] = kondisiDetail
        record["createdAt"] = createdAt
        record["updatedAt"] = updatedAt
    }

    func apply(from record: CKRecord) {
        nama = record["nama"] as? String ?? ""
        jenis = JenisObat(rawValue: record["jenis"] as? String ?? "") ?? .tablet
        dosis = record["dosis"] as? String ?? ""
        frekuensi = record["frekuensi"] as? String ?? ""
        keterangan = KeteranganObat(rawValue: record["keterangan"] as? String ?? "") ?? .sesudahMakan
        isKondisional = record["isKondisional"] as? Bool ?? false
        kondisiDetail = record["kondisiDetail"] as? String
        createdAt = record["createdAt"] as? Date ?? .now
        updatedAt = record["updatedAt"] as? Date ?? .now
        ckRecordName = record.recordID.recordName
    }
}
