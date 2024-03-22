//
//  Device.swift
//  SubtitlesIRL
//
//  Created by David on 3/16/24.
//

import Foundation
import SwiftUI

struct Device: Decodable {
    var t: String?
}

struct DeviceResponse: Decodable {
    var success: Bool
    var data: Device
    var error: String?
}

class DeviceObservable: ObservableObject {
    @Published var data: Device
    @Published var isLoading = false
    @Published var error: Error?
    
    init() {
        data = Device()
        isLoading = false
    }
    
    func saveDeviceId(appState: AppState) async {
        do {
            print("Creating Device")
            
            let deviceId = await UIDevice.current.identifierForVendor!.uuidString
            print("DeviceId: \(deviceId)")
            
            let currentDate = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let formattedDate = formatter.string(from: currentDate)
            let hash = Sha.sha256Hash(for: "\(deviceId)-\(formattedDate)-ios")
            
            let body: [String: String] = ["uniqueId": deviceId, "os": "ios", "time": formattedDate, "hash": hash]
            DispatchQueue.main.async {
                self.isLoading = true
            }
            
            let url = Urls.deviceUrl
            
            let data: DeviceResponse = try await PostData.postJSONData(url: url,
                                                                         appState: appState,
                                                                         body: try! JSONSerialization.data(
                withJSONObject: body,
                options: []
                )
            )
            
//            print("Device created, have token \(data.data.t ?? "")")
            
            DispatchQueue.main.async {
                if (data.success) {
                    self.data = data.data
                }
            
                self.isLoading = false
                self.handleAfterLoaded(appState)
            }
        } catch {
            DispatchQueue.main.async {
                self.error = error
                print("Error while fetching: \(error)")
                self.isLoading = false
            }
        }
    }
    
    func handleAfterLoaded(_ appState: AppState) {
        Task {
        }
    }
}
