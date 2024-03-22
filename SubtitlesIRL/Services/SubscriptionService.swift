//
//  SubscriptionService.swift
//  SubtitlesIRL
//
//  Created by David on 3/21/24.
//

import Foundation
import StoreKit

class SubscriptionService: NSObject, SKRequestDelegate {
    static let shared = SubscriptionService()
    private let receiptValidationURLString = "YOUR_SERVER_ENDPOINT" // Your server endpoint that handles receipt validation with Apple

    override init() {
        super.init()
    }

    func checkActiveSubscription(appState: AppState) {
        fetchReceipt { receiptData in
            guard let receiptString = receiptData?.base64EncodedString(options: []) else {
                return
            }
            
            Task {
                await Subscription.submitReceipt(appState: appState, receiptString: receiptString)
            }
        }
    }

    private func fetchReceipt(completion: @escaping (Data?) -> Void) {
        guard let receiptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: receiptURL.path) else {
            // Receipt doesn't exist, refresh it
            let request = SKReceiptRefreshRequest()
            request.delegate = self
            request.start()
            completion(nil)
            return
        }
        
        do {
            let receiptData = try Data(contentsOf: receiptURL)
            completion(receiptData)
        } catch {
            print("Couldn't read receipt data with error: \(error)")
            completion(nil)
        }
    }
//    
//    func requestDidFinish(_ request: SKRequest) {
//        // Called when the receipt refresh request has finished.
//        // Attempt to fetch the receipt again.
//        fetchReceipt { [weak self] receiptData in
//            guard let receiptString = receiptData?.base64EncodedString(options: []) else {
//                return
//            }
//            
//            print("Receipt string: \(receiptString)")
//            
//            
////            self?.validateReceipt(receiptString: receiptString, completion: { _ in })
//        }
//    }

//    private func validateReceipt(receiptString: String, completion: @escaping (Bool) -> Void) {
//        guard let url = URL(string: receiptValidationURLString) else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        let payload = "{\"receiptString\": \"\(receiptString)\"}"
//        request.httpBody = payload.data(using: .utf8)
//
//        let task = URLSession.shared.dataTask(with: request) { data, _, error in
//            guard let data = data, error == nil else {
//                completion(false)
//                return
//            }
//
//            do {
//                // Assuming the server responds with a simple JSON indicating the subscription status
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let status = json["isSubscriptionActive"] as? Bool {
//                    completion(status)
//                } else {
//                    completion(false)
//                }
//            } catch {
//                print("Error parsing receipt validation response: \(error)")
//                completion(false)
//            }
//        }
//        task.resume()
//    }
}
