//
//  AppDelegate.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 27/07/26.
//

import UIKit
import SwiftData
import CloudKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static var modelContainer: ModelContainer!
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
    
    nonisolated func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        guard let notification = CKNotification(fromRemoteNotificationDictionary: userInfo),
              let zoneNotification = notification as? CKRecordZoneNotification,
              let zoneID = zoneNotification.recordZoneID else {
            completionHandler(.noData)
            return
        }
        let zoneName = zoneID.zoneName
        
        Task { @MainActor in
            let context = ModelContext(AppDelegate.modelContainer)
            do {
                let careGroups = try context.fetch(FetchDescriptor<CareGroupModel>())
                if let careGroup = careGroups.first(where: { $0.zoneName == zoneName }) {
                    await ShareSyncService.shared.performSync(for: careGroup, context: context)
                    completionHandler(.newData)
                    return
                }
            } catch {
                print("Gagal sync dari push notification: \(error)")
            }
            completionHandler(.noData)
        }
    }
}

