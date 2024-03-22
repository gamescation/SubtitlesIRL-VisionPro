//
//  ContentView.swift
//  SubtitlesIRL
//
//  Created by David on 3/15/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation
import Speech

struct PermissionsView: View {
    @Environment(\.supportsMultipleWindows) private var supportsMultipleWindows
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    var appState: AppState
    @State var permissionsGranted: Int = 0
    @State var permissionsNeeded: Int = 2
    @State var error: String = ""
    
    func getStarted() {
        requestMicrophonePermission()
    }
    
    func openSubtitles() {
        print("permissions granted: \(permissionsGranted)")
        if permissionsGranted >= permissionsNeeded {
            appState.permissionsGranted = true
//            openWindow(id: "subtitles")
            dismissWindow(id: "permissions")
        }
    }
    
    func checkMicrophonePermission() {
        permissionsGranted = 0
        switch AVAudioApplication.shared.recordPermission {
        case .undetermined:
            // The user has not yet been asked for microphone permission.
            print("Undetermined")
        case .denied:
            // The user has previously denied the request.
            print("Microphone permission denied.")
            error = "If you previously denied Microphone permissions, you'll need to change them in your settings."
            // Optionally, direct the user to the app settings.
        case .granted:
            // The permission was already granted.
            print("Microphone permission already granted.")
            permissionsGranted += 1
        @unknown default:
            fatalError("Unknown state for AVAudioSession record permission")
        }
        
        switch SFSpeechRecognizer.authorizationStatus() {
            case .authorized:
                permissionsGranted += 1
            case .notDetermined:
                print("Speech not determined")
            case .denied:
                print("Speech Access Denied")
                error = "If you previously denied Microphone permissions, you'll need to change them in your settings."
            case .restricted:
                print("Speech Access Restricted")
            @unknown default:
                print("Speech Access Unknown")
            }
        
        openSubtitles()
    }
    
    func requestMicrophonePermission() {
        permissionsGranted = 0
        
        switch AVAudioApplication.shared.recordPermission {
        case .undetermined:
            // The user has not yet been asked for microphone permission.
            AVAudioApplication.requestRecordPermission { granted in
                if granted {
                    // Permission was granted
                    print("Microphone permission granted.")
                    permissionsGranted += 1
                    openSubtitles()
                } else {
                    // Permission was denied
                    print("Microphone permission denied.")
                    error = "If you denied Microphone permissions, you'll need to change them in your settings."
                }
            }
        case .denied:
            // The user has previously denied the request.
            print("Microphone permission denied.")
            error = "If you denied Microphone permissions, you'll need to change them in your settings."
            // Optionally, direct the user to the app settings.
        case .granted:
            // The permission was already granted.
            print("Microphone permission already granted.")
            permissionsGranted += 1
        @unknown default:
            fatalError("Unknown state for AVAudioSession record permission")
        }
        
        
        switch SFSpeechRecognizer.authorizationStatus() {
            case .authorized:
                print("Speech Recognizer authorized")
                permissionsGranted += 1
            case .notDetermined:
                print("Speech access not determined")
                SFSpeechRecognizer.requestAuthorization { status in
                    switch status {
                    case .authorized:
                        // Permission granted
                        print("Speech Access permission granted")
                        permissionsGranted += 1
                        openSubtitles()
                    default:
                        // Handle the error
                        break
                    }
                }
            case .denied:
                print("Speech Access Denied")
                error = "If you previously denied Speech permissions, you'll need to change them in your settings."
            case .restricted:
                print("Speech Access Restricted")
                permissionsGranted += 1
            @unknown default:
                print("Speech Access Unknown")
            }
        print("opening subtitles")
        openSubtitles()
    }
    
    
    var body: some View {
        VStack {
            Text("SUBTITLES IRL")
                .font(.system(size: 50))
                .bold()
            
            VStack {
                Text("• Generate subtitles in your language")
                    .frame(width: 888, alignment: .leading)
                    .font(.system(size: 40))
                
                Text("• Keep recordings and transcripts of your conversations for later")
                    .frame(width: 888, alignment: .leading)
                    .font(.system(size: 40))
                
                Text("• Make it easy to review what was said")
                    .frame(width: 888, alignment: .leading)
                    .font(.system(size: 40))
                
                Text("• (Coming Soon) Translations of other languages in your language")
                    .frame(width: 888, alignment: .leading)
                    .font(.system(size: 40))
                
            }.padding(50)
            
            HStack {
                Text("Permission to access your microphone and speech is required.")
                    .bold()
                    .font(.system(size: 40))
            }.frame(width: 1000, alignment: .center)
            
            if error != "" {
                Text(error)
                    .bold()
                    .font(.system(size: 40))
            }
            
            Button(action: {
                getStarted()
            }) {
                // Label for your button
                Text("Get Started")
                    .font(.system(size: 40))
                    .padding(.vertical, 30)
                    .padding(.horizontal, 20)
                    .cornerRadius(10)
                    .clipShape(Capsule())
                    
            }
            .cornerRadius(10)
            .clipShape(Capsule())
            .background(Color.blue) // Optional: Set background color
            .foregroundColor(.white)
            .cornerRadius(100)
            .offset(y: 20)
            .hoverEffect(.automatic)
        }
        .onAppear {
            checkMicrophonePermission()
            
            Task {
                await Event.create(appState: appState, name:
                                    "PermissionsViewed")
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    PermissionsView(appState: AppState())
}
