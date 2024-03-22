//
//  HomeView.swift
//  SubtitlesIRL
//
//  Created by David on 3/16/24.
//

import Foundation
import SwiftUI

struct HomeView: View {
    var appState: AppState
    
    var body: some View {
        VStack {
            switch (appState.activeView) {
            case Views.Home:
                PermissionsView(appState: appState)
            }
        }
    }
}
