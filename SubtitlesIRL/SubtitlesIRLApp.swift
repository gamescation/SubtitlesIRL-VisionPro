//
//  SubtitlesIRLApp.swift
//  SubtitlesIRL
//
//  Created by David on 3/15/24.
//

import SwiftUI

@main
struct SubtitlesIRLApp: App {
    @Bindable var appState: AppState = AppState()
    
    init() {
        appState.getDeviceToken()
    }
    
    var body: some Scene {
        WindowGroup {
            if appState.permissionsGranted {
                SubtitlesView(appState: self.appState)
            } else {
                HomeView(appState: appState)
            }
        }
        
        WindowGroup(id: "permissions") {
            HomeView(appState: appState)
        }
        .defaultSize(width: 1200, height: 1000)
        .windowResizability(.automatic)
        
        WindowGroup(id: "subtitles") {
            SubtitlesView(appState: self.appState)
        }
        .defaultSize(width: 1000, height: 100)
        .windowResizability(.automatic)
        .windowStyle(.volumetric)
        
        WindowGroup(id: "history") {
            HistoryView(appState: self.appState)
        }
        .defaultSize(width: 1000, height: 1000, depth: 50)
        .windowResizability(.automatic)
        .windowStyle(.volumetric)
        
        
        WindowGroup(id: "historySubscription") {
            HistorySubscriptionView(appState: self.appState)
        }
        .defaultSize(width: 1000, height: 1000, depth: 50)
        .windowResizability(.automatic)
        .windowStyle(.automatic)

//
//        ImmersiveSpace(id: "ImmersiveSpace") {
//            ImmersiveView()
//        }
    }
}
