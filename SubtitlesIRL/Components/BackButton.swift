//
//  BackButton.swift
//  SubtitlesIRL
//
//  Created by David on 3/20/24.
//

import Foundation
import SwiftUI

struct BackButton: View {
    var appState: AppState
    var backView: Views = Views.Home

    func onBackTap() {
        self.appState.goBack()
    }
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.left") // SF Symbols for back arrow
                .aspectRatio(contentMode: .fit)
        }
        .padding(35)
        .padding([.leading, .trailing], 20)
        .font(.system(size: 85))
        .foregroundColor(.white)
        .background(.black)
        .opacity(0.9)
        .cornerRadius(10)
        .offset(z: 700)
        .offset(x: -550, y: 0)
        .onTapGesture {
            self.onBackTap()
        }
    }
}
