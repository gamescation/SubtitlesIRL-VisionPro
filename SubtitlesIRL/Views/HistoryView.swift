//
//  HistoryView.swift
//  SubtitlesIRL
//
//  Created by David on 3/18/24.
//

import Foundation
import SwiftUI
import CoreData
import RealityKit

struct HistoryView: View {
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    var appState: AppState
    @ObservedObject var audioPlayerService: AudioPlayerService = AudioPlayerService()
    @State var showRecording: RecordingModel?
    @Environment(\.scenePhase) private var scenePhase
    @State var showAlert: Bool = false
    @State private var search: String = ""
    @FocusState private var searchIsFocused: Bool
    @State private var recordings: [RecordingModel] = []
    
    func fetchRecordings() {
        let dateSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let managedContext = CoreDataManager.shared.viewContext
        
        
        do {
            let fetchRequest: NSFetchRequest<RecordingModel> = RecordingModel.fetchRequest()
            if search != "" {
                fetchRequest.predicate = NSPredicate(format: "transcript CONTAINS[cd] %@", search)
            }
            
            fetchRequest.sortDescriptors = [dateSortDescriptor]
            
            self.recordings = try managedContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch events: \(error)")
        }
    }
    
    func getSubtitles(recording: RecordingModel) -> [Segment] {
        var subtitles: [Segment] = []
        recording.subtitles?.forEach { subtitle in
            let segment = subtitle as! SubtitleModel
//            print("Segment: \(segment.id?.uuidString ?? "") \(segment.text ?? "")")
            subtitles.append(Segment(id: segment.id, text: segment.text!, date: segment.date!))
        }
        return subtitles.sorted(by: { $0.date < $1.date })
    }
    
    func showUnlockHistory() {
        openWindow(id: "historySubscription")
        dismissWindow(id: "history")
    }

    var body: some View {
        VStack {
            if showRecording != nil {
                let recording = showRecording
                VStack {
                    HStack {
                        HStack {
                            Image(systemName: "arrow.left")
                                .resizable()// SF Symbols for back arrow
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                        }
                        .hoverEffect(.highlight)
                        .padding(10)
                        .padding([.leading, .trailing], 10)
                        .font(.system(size: 85))
                        .foregroundColor(.white)
                        .background(.black)
                        .opacity(0.8)
                        .cornerRadius(10)
                        .offset(x: 35, y: 10)
                        .offset(z: 1)
                        .frame(width: 30, height: 30, alignment: .leading)
                        .onTapGesture {
                            showRecording = nil
                        }
                    }.frame(width: 1000, alignment: .leading)
                    ScrollView(.vertical) {
                        VStack {
                            let subtitles: [Segment] = getSubtitles(recording: recording!)
                            
                        
                            ForEach(subtitles) { subtitle in
                                HStack {
                                    Group {
                                        Text(subtitle.date.formatted())
                                            .font(.system(size: 25))
                                            .frame(width: 300)
                                        
                                        Text(subtitle.text)
                                            .font(.system(size: 25))
                                            .frame(width: 650, alignment: .leading)
                                    }
                                }
                            }
                        
                            
                        }.frame(width: 1000, alignment: .leading)
                    }
                    .frame(height: 750, alignment: .leading)
                    .offset(y: 20)
                    
                    VStack {
                        AudioPlayerView(audioPlayerService: audioPlayerService, recording: recording!, appState: appState)
                            .padding()
                            .frame(width: 800)
                    }
                    .frame(width: 1000, alignment: .center)
                    .offset(y: 20)
                }.padding(50)
                .foregroundColor(.white)
                .background(.black)
                .opacity(0.85)
                .cornerRadius(20)
                .onAppear {
                    Task {
                        await Event.create(appState: appState, name:
                                            "HistoryRecordingViewed")
                    }
                }
                
            } else {
                VStack {
                    HStack {
                        ZStack {
                            if !appState.unlockedHistory {
                                ZStack {
                                    HStack {
                                        LockIconView()
                                        
                                        Text("Unlock Search for Just $0.99/month")
                                            .font(.system(size: 25))
                                            .padding()
                                    }
                                }
                                .padding(50)
                                .frame(width: 800, alignment: .center)
                                .foregroundColor(.white)
                                .background(.black)
                                .cornerRadius(10)
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                                .offset(z: 10)
                                .onTapGesture {
                                    showUnlockHistory()
                                }
                            }
                            
                            TextField(
                                "Search",
                                text: $search,
                                prompt: Text("Search").foregroundColor(.white)
                            )
                            .padding(30)
                            .frame(width: 800)
                            .opacity(searchIsFocused ? 1: 0.5)
                            .focused($searchIsFocused)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(false)
//                            .border(.secondary)
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(RoundedRectangle(cornerRadius: 50).fill(Color.black))
                            .cornerRadius(10)
                            .onChange(of: search) {
                                if appState.unlockedHistory {
                                    fetchRecordings()
                                }
                            }
                        }
                        
                        Text("Clear Data")
                            .hoverEffect(.highlight)
                            .padding(20)
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .background(.black)
                            .cornerRadius(10)
                            .opacity(0.9)
                            .offset(x: 10)
                            .onTapGesture {
                                showAlert = true
                            }
                            .alert(isPresented: $showAlert) {
                                Alert(
                                    title: Text("Are you sure?"),
                                    message: Text("This will delete all transcripts and recordings."),
                                    primaryButton: .destructive(Text("Yes")) {
                                        CoreDataService.clearAllData(entity: "SubtitleModel")
                                        CoreDataService.clearAllData(entity: "RecordingModel")
                                        audioPlayerService.clearAllData()
                                        dismissWindow(id: "history")
                                    },
                                    secondaryButton: .default(Text("Cancel"), action: {
                                        // Perform an action when the alert is dismissed
                                        showAlert = false
                                    })
                                )
                                
                            }
                    }
                    ScrollView(.vertical) {
                        ForEach(self.recordings.indices, id: \.self) { index in
                            let recording = recordings[index]
                            
                            ZStack {
                                if index > 0 && !appState.unlockedHistory {
                                    ZStack {
                                        HStack {
                                            LockIconView()
                                            
                                            Text("Unlock All Your Recordings and Transcripts for Just $0.99/month")
                                                .font(.system(size: 25))
                                                .padding()
                                        }
                                    }
                                    .padding(50)
                                    .frame(width: 1000, alignment: .center)
                                    .foregroundColor(.white)
                                    .background(.black)
                                    .cornerRadius(10)
                                    .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                                    .offset(z: 10)
                                    .onTapGesture {
                                        showUnlockHistory()
                                    }
                                }
                                HStack {
                                    VStack {
                                        Text(recording.date?.formatted() ?? "Unknown Date")
                                            .font(.system(size: 30))
                                    }.frame(width: 300, alignment: .leading)
                                    
                                    VStack {
                                        Text("\(truncate(recording.transcript ?? "No transcript", toLength: 40))")
                                            .font(.system(size: 30))
                                    }.frame(width: 650, alignment: .leading)
                                }
                                .padding(50)
                                .frame(width: 1000)
                                .foregroundColor(.white)
                                .background(.black)
                                .cornerRadius(10)
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                                .onTapGesture {
                                    if index > 0 && !appState.unlockedHistory {
                                        showUnlockHistory()
                                    } else {
                                        showRecording = recording
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 900, alignment: .leading)
                }.frame(height: 1000, alignment: .leading)
        
            }
        }.environmentObject(audioPlayerService)
        .onChange(of: scenePhase) { newPhase, scenePhase in
            print("ScenePhase - NewScenePhase: \(scenePhase) - \(newPhase)")
            switch newPhase {
            case .active:
                // App becomes active
                break
            case .inactive:
                // App becomes inactive
                break
            case .background:
                // App goes into the background
                print("Backgrounded")
                if ((audioPlayerService.audioPlayer?.isPlaying) != nil) {
                    print("Stopping Audio Play")
                    audioPlayerService.stop()
                }
            @unknown default:
                break
            }
        }
        .onAppear {
            fetchRecordings()
            
            Task {
                await Event.create(appState: appState, name:
                                    "HistoryViewed")
            }
        }
    }
}
