//
//  SharedModelContainer.swift
//  A09_C3
//
//  Created by Muhammad Dzakki Abdullah on 27/07/26.
//

import Foundation
import SwiftData

enum SharedModelContainer {
    static let appGroupID = "group.com.challenge3.A09-C3"

    static let container: ModelContainer = {
        let schema = Schema([
            Obat.self,
            PantauanModel.self,
            KonsulModel.self,
            CareGroupModel.self,
            
        ])

        guard let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("A09_C3.sqlite") else {
            fatalError("Tidak bisa mengakses App Group container")
        }

        let configuration = ModelConfiguration(schema: schema, url: groupURL,cloudKitDatabase: .none)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create shared ModelContainer: \(error)")
        }
    }()
}
