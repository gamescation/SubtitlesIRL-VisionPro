//
//  LockIconView.swift
//  SubtitlesIRL
//
//  Created by David on 3/20/24.
//

import Foundation
import SwiftUI

struct LockIconView: View {
    var body: some View {
        Image(systemName: "lock.square.fill")
            .resizable()
            .frame(width: 50, height: 50)
            .hoverEffect(.automatic)
    }
}
