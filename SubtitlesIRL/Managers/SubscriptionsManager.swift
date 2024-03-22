//
//  SubscriptionsManager.swift
//  SubtitlesIRL
//
//  Created by David on 3/20/24.
//

import Foundation
import StoreKit
import SwiftUI

class SubscriptionManager: NSObject, ObservableObject, SKPaymentTransactionObserver {
    @Published var transactionState: SKPaymentTransactionState?
    @Published var subscriptions = [SKProduct]()
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    var appState: AppState?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("In payment queue")
        for transaction in transactions {
            // Handle transaction states (purchased, failed, restored, etc.)
            print("Transaction: \(transaction)")
            switch transaction.transactionState {
                case .purchasing:
                    print("Purchasing")
                    transactionState = .purchasing
                case .purchased, .restored:
                    print("Payment success")
                    print("\(transaction.payment.productIdentifier)")
                    transactionState = .purchased
                    // Unlock subscription features
//                    UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                    appState?.unlockedHistory = true
                    queue.finishTransaction(transaction)
                case .failed:
                    // Handle error
                    print("Failed")
                    transactionState = .failed
                    queue.finishTransaction(transaction)
                default:
                    print("Default")
                    queue.finishTransaction(transaction)
                    break
            }
        }
    }

    private let productID = "History"

    func fetchProducts() {
        let request = SKProductsRequest(productIdentifiers: Set([productID]))
        request.delegate = self
        request.start()
    }
    
    func purchase(subscription: SKProduct) {
        print("Purchasing: \(subscription.productIdentifier)")
        let payment = SKPayment(product: subscription)
        SKPaymentQueue.default().add(payment)
    }
}

extension SubscriptionManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            print("Products: \(response.products.first?.productIdentifier ?? "No first product")")
//            print("Product: \(response.products.first?.localizedTitle ?? "")")
//            print("Product: \(response.products.first?.price.stringValue ?? "")")
            self.subscriptions = response.products
        }
    }
}
