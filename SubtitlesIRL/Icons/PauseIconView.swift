//
//  PauseIconView.swift
//  SubtitlesIRL
//
//  Created by David on 3/19/24.
//

import Foundation
import SwiftUI

struct PauseIconView: View {
    var body: some View {
        Image(systemName: "pause.circle")
            .resizable()
            .frame(width: 50, height: 50)
            .hoverEffect(.automatic)
    }
}
