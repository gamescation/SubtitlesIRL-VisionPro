//
//  Sha.swift
//  SubtitlesIRL
//
//  Created by David on 3/21/24.
//

import Foundation
import CryptoKit

struct Sha {
    static func sha256Hash(for input: String) -> String {
        // Convert String to Data
        let inputData = Data(input.utf8)
        
        // Hash the data
        let hashedData = SHA256.hash(data: inputData)
        
        // Convert the SHA-256 hash to a hexadecimal string
        let hashString = hashedData.compactMap { String(format: "%02x", $0) }.joined()
        
        return hashString
    }
}
