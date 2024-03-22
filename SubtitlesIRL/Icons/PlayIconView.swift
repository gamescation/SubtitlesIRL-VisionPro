//
//  PlayIcon.swift
//  SubtitlesIRL
//
//  Created by David on 3/18/24.
//

import Foundation
import SwiftUI

struct PlayIconView: View {
    var body: some View {
        Image(systemName: "play.circle")
            .resizable()
            .frame(width: 50, height: 50)
            .hoverEffect(.automatic)
    }
}
