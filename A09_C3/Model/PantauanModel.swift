//
//  PantauanModel.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 15/07/26.
//
import Foundation
import SwiftData

@Model
final class PantauanModel {
    var id: UUID = UUID()
    var pantauanDate: Date = Date.now
    var pantauanBody: String = ""
    var pantauanCreatedAt: Date = Date.now
    var pantauanUpdatedAt: Date?
    
    var careGroup: CareGroupModel?
    var ckRecordName: String?
    
    init(
        pantauanDate: Date = Date.now,
        pantauanBody: String = ""
    ) {
        self.pantauanDate = pantauanDate
        self.pantauanBody = pantauanBody
    }
}
