//
//  CalendarIconView.swift
//  SubtitlesIRL
//
//  Created by David on 3/18/24.
//

import Foundation
import SwiftUI

struct CalendarIconView: View {
    var body: some View {
        Image(systemName: "calendar")
            .resizable()
            .frame(width: 30, height: 30)
            .hoverEffect(.automatic)
    }
}
