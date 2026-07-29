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
    
    var sharedModelContainer: ModelContainer = SharedModelContainer.container

    @State private var translationBridge = TranslationBridge()
    private let widgetRefreshObserver = WidgetRefreshObserver() 
    
    init() {
            try? Tips.resetDatastore()
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        
        UIView.appearance(whenContainedInInstancesOf: [TipUIPopoverViewController.self])
            .tintColor = UIColor(named: "tip")
        
        AppDelegate.modelContainer = sharedModelContainer
    }
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(translationBridge)
                .overlay(TranslationHostView(bridge: translationBridge))
                .onOpenURL { url in
                    if url.scheme == "a09c3" && url.host == "obat" {
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
