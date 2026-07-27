//
//  SceneDelegate.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 27/07/26.
//

import UIKit
import CloudKit
import SwiftData

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func windowScene(
        _ windowScene: UIWindowScene,
        userDidAcceptCloudKitShareWith metadata: CKShare.Metadata
    ) {
        Task { @MainActor in
            let context = ModelContext(AppDelegate.modelContainer)
            do {
                try await ShareSyncService.shared.acceptShare(metadata: metadata, context: context)
            } catch {
                print("Gagal menerima share: \(error)")
            }
        }
    }
}
