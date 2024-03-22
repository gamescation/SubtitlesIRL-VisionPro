//
//  Txt.swift
//  SubtitlesIRL
//
//  Created by David on 3/17/24.
//

import Foundation
import SwiftUI

struct Txt: View {
    var content = ""
    var foregroundColor: Color = .white
    var backgroundColor: Color = .black
    var cornerRadius: CGFloat = 10
    var fontSize: CGFloat = 50
    @State var isHovered: Bool = false
    
    
    @inlinable public init(_ content: String) {
        self.content = content
    }
    
    init(content: String, foregroundColor: Color = .white, backgroundColor: Color = .black, cornerRadius: CGFloat = 10, fontSize: CGFloat = 50) {
        self.content = content
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.fontSize = fontSize
    }
    
    var body: some View {
        Text(content)
            .hoverEffect(.highlight)
            .padding(30)
            .font(.system(size: fontSize))
            .foregroundColor(self.foregroundColor)
            .background(self.backgroundColor)
            .cornerRadius(cornerRadius)
            .opacity(isHovered ? 1: 0.9)
            .offset(z: 1000)
    }
}
