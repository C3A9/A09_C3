//
//  CareGroupModel.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 27/07/26.
//

import Foundation
import SwiftData
import CloudKit

@Model
final class CareGroupModel {
    var id: UUID = UUID()
    var patientName: String = ""
    var zoneName: String = ""
    var rootRecordName: String = ""
    var isOwner: Bool = true
    var hasMigratedLegacyData: Bool = false 
    var createdAt: Date = Date.now
    var zoneOwnerName: String = CKCurrentUserDefaultName

    @Relationship(deleteRule: .cascade, inverse: \Obat.careGroup)
    var obatList: [Obat]? = []
    @Relationship(deleteRule: .cascade, inverse: \PantauanModel.careGroup)
    var pantauanList: [PantauanModel]? = []
    @Relationship(deleteRule: .cascade, inverse: \KonsulModel.careGroup)
    var konsulList: [KonsulModel]? = []

    init(patientName: String = "") {
        self.patientName = patientName
    }
}
