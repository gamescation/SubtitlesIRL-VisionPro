//
//  SubtitlesView.swift
//  SubtitlesIRL
//
//  Created by David on 3/16/24.
//

import Foundation
import SwiftUI
import AVFoundation
import Speech

struct SubtitlesView: View {
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    var appState: AppState
    @State var recording: Bool = false
    @State private var scale: CGFloat = 1.0
    var speechRecognizerService = SpeechRecognizerService()
    
    init(appState: AppState) {
        self.appState = appState
        speechRecognizerService.appState = appState
        speechRecognizerService.updateAppState()
    }
    
    func toggleRecording() {
        recording.toggle()
        
        if recording {
           print("Recording")
            do {
//                audioRecorderService.startRecording()
                try speechRecognizerService.startRecording()
            } catch {
                print("Error while recording \(error)")
            }
            
            Task {
                await Event.create(appState: appState, name:
                                    "RecordPressed")
            }
        } else {
            print("Stopping recording")
            speechRecognizerService.stopRecording()
            
            Task {
                await Event.create(appState: appState, name:
                                    "RecordingStopped")
            }
        }
    }
    
    func showHistory() {
        openWindow(id: "history")
    }
    
    var body: some View {
        VStack {
            if appState.subtitle != "" {
                ZStack {
                    Txt(appState.subtitle)
                }
                .onAppear {
                    Task {
                        await Event.create(appState: appState, name:
                                            "SubtitleViewed")
                    }
                }
            }
            HStack {
                ZStack {
                    // Expanding circle
                    if recording {
                        Circle()
                            .fill(Color.red.opacity(0.5)) // Semi-transparent red circle
                            .scaleEffect(scale) // Bind the scale of the circle to your state variable
                            .frame(width: 40, height: 40)
                            .offset(z: 1)
                            .animation(.easeOut(duration: 2).repeatForever(autoreverses: true), value: scale)
                            .onAppear {
                                self.scale = 2.0 // Start the animation by changing the scale
                            }
                            .onDisappear {
                                self.scale = 1.0
                            }
                    }
                    // Animate the scale change
                    
                    Button(action: {
                        // Action for the button tap
                        toggleRecording()
                    }) {
                        // Label for the button, using an Image or Text
                        Text("")
                            .padding(20) // Padding around the text to increase the button's size
                            .background(Circle() // Use Circle shape as the background
                                .fill(Color.red)) // Fill the circle with red color
                        
                        if !recording {
                            Text("Record")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .padding(10)
                        }
                    }
                    .cornerRadius(50)
                    .hoverEffect(.automatic)
                }
                .frame(width: 200, height: 130)
                .offset(z: 1280)
                
                if appState.recordingsCount > 0 && !recording  {
                    ZStack {
                        Button(action: {
                            // Action for the button tap
                            showHistory()
                        }) {
                            HStack {
                                CalendarIconView()
                                    .padding()
                                
                                Text("History")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .offset(x: -5)
                            }
                            .padding(10)
                        }
                        .cornerRadius(50)
                        .hoverEffect(.automatic)
                    }.frame(width: 250, height: 130)
                        .offset(z: 1280)
                }
            }
        }
        .onAppear {
            if appState.permissionsGranted {
                dismissWindow(id: "permissions")
            } else {
                openWindow(id: "permissions")
            }
            
            Task {
                await Event.create(appState: appState, name:
                                    "RecordView")
            }
        }
    }
}
