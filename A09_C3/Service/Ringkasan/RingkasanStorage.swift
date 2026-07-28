//
//  RingkasanStorage.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 23/07/26.
//

import Foundation

struct CachedPoin: Codable {
    let sourceText: String  
    let text: String
    let generatedAt: Date
}

enum RingkasanStorage {
    private static let pantauanKey = "ringkasan.pantauan.cache"
    private static let konsultasiKey = "ringkasan.konsultasi.cache"

    static func loadPantauanCache() -> [UUID: CachedPoin] {
        guard let data = UserDefaults.standard.data(forKey: pantauanKey),
              let decoded = try? JSONDecoder().decode([String: CachedPoin].self, from: data) else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: decoded.compactMap { key, value in
            guard let uuid = UUID(uuidString: key) else { return nil }
            return (uuid, value)
        })
    }

    static func savePantauanCache(_ cache: [UUID: CachedPoin]) {
        let encodable = Dictionary(uniqueKeysWithValues: cache.map { ($0.key.uuidString, $0.value) })
        if let data = try? JSONEncoder().encode(encodable) {
            UserDefaults.standard.set(data, forKey: pantauanKey)
        }
    }

    static func loadKonsultasiCache() -> [UUID: CachedPoin] {
        guard let data = UserDefaults.standard.data(forKey: konsultasiKey),
              let decoded = try? JSONDecoder().decode([String: CachedPoin].self, from: data) else {
            return [:]
        }
        return Dictionary(uniqueKeysWithValues: decoded.compactMap { key, value in
            guard let uuid = UUID(uuidString: key) else { return nil }
            return (uuid, value)
        })
    }

    static func saveKonsultasiCache(_ cache: [UUID: CachedPoin]) {
        let encodable = Dictionary(uniqueKeysWithValues: cache.map { ($0.key.uuidString, $0.value) })
        if let data = try? JSONEncoder().encode(encodable) {
            UserDefaults.standard.set(data, forKey: konsultasiKey)
        }
    }
}
