//
//  AppState.swift
//  SubtitlesIRL
//
//  Created by David on 3/16/24.
//
import Foundation
import SwiftUI

@Observable
class AppState {
    var device: DeviceObservable = DeviceObservable()
    var activeView: Views = Views.Home
    var permissionsGranted: Bool = false
    var showHistorySubscriptionView: Bool = false
    var subtitle: String = ""
    var subtitles: [String] = []
    var back: [Views] = []
    var recordingsCount: Int = 0
    var unlockedHistory: Bool = false
    func getDeviceToken() {
        Task {
            await device.saveDeviceId(appState: self)
            
            await self.checkActiveSubscriptions()
        }
    }
    
    func checkActiveSubscriptions() async {
        SubscriptionService.shared.checkActiveSubscription(appState: self)
    }
    
    func goBack() {
        let backView = self.back.popLast()
        self.activeView = backView!
    }
    
    func changeView(view: Views) {
        back.append(activeView)
        activeView = view
    }
    
    @MainActor
    static func previewAppState() -> AppState {
        let state = AppState()

        return state
    }
}
