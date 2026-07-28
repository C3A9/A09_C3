//
//  KategoriObatPilihan.swift
//  ObatWidgetExtension
//
//  Created by Muhammad Dzakki Abdullah on 27/07/26.
//

import AppIntents

enum KategoriObatPilihan: String, AppEnum {
    case rutin
    case kondisional

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Kategori Obat"
    static var caseDisplayRepresentations: [KategoriObatPilihan: DisplayRepresentation] = [
        .rutin: "Rutin",
        .kondisional: "Kondisional"
    ]
}
