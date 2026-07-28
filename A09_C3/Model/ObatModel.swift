//
//  ObatModel.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 15/07/26.
//

import SwiftData
import Foundation

@Model
class Obat {
    var id: UUID = UUID()
    var nama: String = ""
    var jenis: JenisObat = JenisObat.tablet
    var dosis: String = ""
    var frekuensi: String = ""
    var keterangan: KeteranganObat = KeteranganObat.sesudahMakan
    var isKondisional: Bool = false
    var kondisiDetail: String? = nil
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now
    
    var careGroup: CareGroupModel?
    var ckRecordName: String?
    
    init(
        id: UUID = UUID(),
        nama: String = "",
        jenis: JenisObat = JenisObat.tablet,
        dosis: String = "",
        frekuensi: String = "",
        keterangan: KeteranganObat = KeteranganObat.sesudahMakan,
        isKondisional: Bool = false,
        kondisiDetail: String? = nil,
        createdAt: Date = Date.now,
        updatedAt: Date = Date.now
    ) {
        self.id = id
        self.nama = nama
        self.jenis = jenis
        self.dosis = dosis
        self.frekuensi = frekuensi
        self.keterangan = keterangan
        self.isKondisional = isKondisional
        self.kondisiDetail = kondisiDetail
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum JenisObat: String, Codable, CaseIterable, Identifiable {
    case tablet = "Tablet"
    case sirup = "Sirup"
    case kapsul = "Kapsul"
    
    var id: String { self.rawValue }
}

enum KeteranganObat: String, Codable, CaseIterable, Identifiable {
    case sebelumMakan = "Sebelum makan"
    case sesudahMakan = "Sesudah makan"
    case saatMakan = "Saat makan"
    
    var id: String { self.rawValue }
}

enum ObatTab: String, CaseIterable, Identifiable {
    case rutin = "Rutin"
    case kondisional = "Kondisional"
    
    var id: String { rawValue }
}
