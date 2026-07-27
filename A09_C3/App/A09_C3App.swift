//
//  A09_C3App.swift
//  A09_C3
//
//  Created by Richie Daryl Kwenandar on 14/07/26.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct A09_C3App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CareGroupModel.self,
            PantauanModel.self,
            Obat.self,
            KonsulModel.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @State private var translationBridge = TranslationBridge()
    
    init() {
            try? Tips.resetDatastore()
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        
        UIView.appearance(whenContainedInInstancesOf: [TipUIPopoverViewController.self])
            .tintColor = UIColor(named: "tip")
        }
        AppDelegate.modelContainer = sharedModelContainer
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(translationBridge)
                .overlay(TranslationHostView(bridge: translationBridge))
        }
        .modelContainer(sharedModelContainer)
    }
}
