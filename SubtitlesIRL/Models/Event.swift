//
//  Subscription.swift
//  SubtitlesIRL
//
//  Created by David on 3/21/24.
//

import Foundation

struct EventResponse: Decodable {
    var success: Bool
}

struct Event {
    static func create(appState: AppState, name: String) async {
        do {
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let formattedDate = formatter.string(from: currentDate)
            let hash = Sha.sha256Hash(for: "\(name)-\(formattedDate)-ios")

            let _: EventResponse = try await PostData.postJSONData(url: Urls.eventsUrl, appState: appState, body: try! JSONSerialization.data( withJSONObject: ["name": name, "time": formattedDate, "os": "ios", "hash": hash], options: [] )
            )
        } catch {
//            print("Error sending event \(error)")
        }
    }
}
