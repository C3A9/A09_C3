//
//  AppDelegate.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 27/07/26.
//

import UIKit
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
    static var modelContainer: ModelContainer!
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
    }
}
