//
//  HistorySubscriptionView.swift
//  SubtitlesIRL
//
//  Created by David on 3/20/24.
//

import Foundation
import SwiftUI

struct HistorySubscriptionView: View {
    var appState: AppState
    @Environment(\.dismissWindow) private var dismissWindow
    @StateObject var subscriptionManager = SubscriptionManager()
    @State var error: String = ""
    
    func subscribe() {
        if let product = subscriptionManager.subscriptions.first(where: { product in
            return product.productIdentifier == "History"
        }) {
            subscriptionManager.purchase(subscription: product)
        } else {
            error = "Could not find subscription. Please try again."
        }
        
        Task {
            await Event.create(appState: appState, name:
                                "SubscribePressed")
        }
    }
    
    func close() {
        dismissWindow(id: "historySubscription")
        
        Task {
            await Event.create(appState: appState, name:
                                "HistorySubscriptionCanceled")
        }
    }
    
    var body: some View {
        VStack {
            Text("Unlock the Power of Unlimited")
                .font(.system(size: 40))
                .padding()
            
                VStack {
                    HStack {
                        VStack {
                            Text("Unlimited Recordings: ")
                                .bold()
                                .font(.system(size: 30))
                        }
                        .frame(width: 350, alignment: .leading)
                        
                        VStack {
                            Text("Capture every conversation, no limits.")
                                .font(.system(size: 25))
                        }.frame(alignment: .leading)
                    }
                    .padding()
                    .frame(width: 800, alignment: .leading)
                    
                    HStack {
                        VStack {
                            Text("Unlimited Transcripts: ")
                                .bold()
                                .font(.system(size: 30))
                        }
                        .frame(width: 350, alignment: .leading)
                        
                        VStack {
                            Text("Get transcriptions for all your recorded conversations")
                                .font(.system(size: 25))
                        }.frame(alignment: .leading)
                    }
                    .padding()
                    .frame(width: 800, alignment: .leading)
                    
                    HStack {
                        VStack {
                            Text("Search Your History:    ")
                                .bold()
                                .font(.system(size: 30))
                        }
                        .frame(width: 350, alignment: .leading)
                        
                        VStack {
                            Text("Navigate through your conversation history effortlessly with search")
                                .font(.system(size: 25))
                                .frame(alignment: .leading)
                        }.frame(alignment: .leading)
                    }
                    .padding()
                    .frame(width: 800, alignment: .leading)
                }
                
                
                Text("Why subscribe?")
                    .font(.system(size: 30))
                    .padding(20)
            
                VStack {
                    HStack {
                        Text("• Enhance Accessibility: Make every conversation accessible, providing support for those with hearing difficulties or anyone who wishes to get more from their conversations.")
                            .font(.system(size: 20))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .frame(width: 800, alignment: .leading)
                    
                    HStack {
                        Text("• Never Miss Important Details: With unlimited recordings and transcripts, ensure you always have a reference for important discussions, instructions, or cherished moments.")
                            .font(.system(size: 20))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .frame(width: 800, alignment: .leading)
                    
                    HStack {
                        Text("• Effortless Organization: Our intuitive search functionality makes managing your conversations a breeze, saving you time and enhancing productivity.")
                            .font(.system(size: 20))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .frame(width: 800, alignment: .leading)
                    
                    HStack {
                        Text("• Privacy Guaranteed: Your conversations kept private. We prioritize your privacy with secure local storage, ensuring only you can access your recordings and transcripts.")
                            .font(.system(size: 20))
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(10)
                    .frame(width: 800, alignment: .leading)
                }.frame(width: 800, alignment: .leading)
                
                HStack {
                    Text("Upgrade to the History Subscription and transform your communication experience with SubtitlesIRL. Your conversations, captured endlessly, available anytime.")
                        .font(.system(size: 25))
                        .bold()
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: 800, alignment: .center)
                .padding(10)
            
            if error != "" {
                Text(error)
            }
            
            HStack {
                Text("Not Now")
                    .hoverEffect(.highlight)
                    .padding(20)
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .background(.black)
                    .cornerRadius(10)
                    .onTapGesture {
                        close()
                    }
                Text("Subscribe")
                    .hoverEffect(.highlight)
                    .padding(20)
                    .font(.system(size: 30))
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(10)
                    .onTapGesture {
                        subscribe()
                    }
            }
        }.onAppear {
            subscriptionManager.appState = appState
            subscriptionManager.fetchProducts()
        
            Task {
                await Event.create(appState: appState, name:
                                    "HistorySubscriptionViewed")
            }
        }
        .onChange(of: appState.unlockedHistory) {
            if appState.unlockedHistory {
                dismissWindow(id: "historySubscription")
            }
        }
    }
}
