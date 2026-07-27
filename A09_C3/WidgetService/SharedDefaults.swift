//
//  SharedDefaults.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 27/07/26.
//

import Foundation

enum SharedDefaults {
    static let suite = UserDefaults(suiteName: SharedModelContainer.appGroupID)!
    private static let selectedKategoriKey = "widget.selectedKategori"

    static var selectedKategori: KategoriObatPilihan {
        get {
            let raw = suite.string(forKey: selectedKategoriKey) ?? KategoriObatPilihan.rutin.rawValue
            return KategoriObatPilihan(rawValue: raw) ?? .rutin
        }
        set {
            suite.set(newValue.rawValue, forKey: selectedKategoriKey)
        }
    }
}
