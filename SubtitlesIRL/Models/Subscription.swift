//
//  Subscription.swift
//  SubtitlesIRL
//
//  Created by David on 3/21/24.
//

import Foundation

struct SubscriptionResponse: Decodable {
    var success: Bool
    var isHistoryActive: Bool
}

struct Subscription {
    static func submitReceipt(appState: AppState, receiptString: String) async {
        do {
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let formattedDate = formatter.string(from: currentDate)
            let hash = Sha.sha256Hash(for: "\(receiptString)-\(formattedDate)-ios")

            let response: SubscriptionResponse = try await PostData.postJSONData(url: Urls.subscriptionReceiptUrl, appState: appState, body: try! JSONSerialization.data( withJSONObject: ["receiptString": receiptString, "time": formattedDate, "os": "ios", "hash": hash], options: [] )
            )
            
            print("\(response)")
            
            if response.isHistoryActive {
                appState.unlockedHistory = true
            }
        } catch {
            print("Error sending receipt data")
        }
    }
}
