//
//  Truncate.swift
//  SubtitlesIRL
//
//  Created by David on 3/18/24.
//

import Foundation
func truncate(_ string: String, toLength length: Int, trailing: String = "...") -> String {
    if string.count > length {
        return String(string.prefix(length)) + trailing
    } else {
        return string
    }
}
