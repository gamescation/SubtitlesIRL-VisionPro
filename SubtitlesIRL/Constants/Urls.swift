//
//  Urls.swift
//  SubtitlesIRL
//
//  Created by David on 3/16/24.
//

import Foundation


struct Urls {
    public static let baseUrl = ProcessInfo.processInfo.environment["BASE_URL"] != nil ? ProcessInfo.processInfo.environment["BASE_URL"]: "https://api.subtitlesirl.com"
    public static let apiUrl = "\(Urls.baseUrl ?? "")/api"
    public static let deviceUrl = "\(Urls.apiUrl)/device"
    public static let eventsUrl = "\(Urls.apiUrl)/events"
    public static let subscriptionReceiptUrl = "\(Urls.apiUrl)/subscription/receipt"
}
