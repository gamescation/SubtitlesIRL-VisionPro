//
//  SubtitlesIRLApp.swift
//  SubtitlesIRL
//
//  Created by David on 3/15/24.
//

import SwiftUI

@main
struct SubtitlesIRLApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
