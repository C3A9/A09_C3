//
//  KonsulModel.swift
//  A09_C3
//
//  Created by Dina on 17/07/26.
//

import Foundation
import SwiftData

@Model
final class KonsulModel {
    var id: UUID = UUID()
    var namaDokter: String = ""
    var tanggalKonsultasi: Date = Date.now
    var content: String = ""
    var konsulCreatedAt: Date = Date.now
    var kosulUpdatedAt: Date?
    
    var careGroup: CareGroupModel?
    var ckRecordName: String?
    
    init(
        namaDokter: String = "",
        tanggalKonsultasi: Date = Date.now,
        content: String = ""
    ) {
        self.namaDokter = namaDokter
        self.tanggalKonsultasi = tanggalKonsultasi
        self.content = content
    }
}
