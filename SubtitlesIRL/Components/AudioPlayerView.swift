//
//  SeekBarView.swift
//  SubtitlesIRL
//
//  Created by David on 3/19/24.
//

import Foundation
import SwiftUI
import CoreMedia

struct AudioPlayerView: View {
    @ObservedObject var audioPlayerService: AudioPlayerService
    @State var currentTime: TimeInterval
    @State var duration: Double = 0.0
    @State var name: String?
    @State var recording: RecordingModel
    @State var playing = false
    var appState: AppState
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init(audioPlayerService: AudioPlayerService, recording: RecordingModel, appState: AppState) {
        self.name = recording.name!
        self.audioPlayerService = audioPlayerService
        audioPlayerService.prepareRecording(name: recording.name!)
        duration = audioPlayerService.audioPlayer?.duration ?? 0.0
        currentTime = audioPlayerService.audioPlayer?.currentTime ?? 0.0
        self.recording = recording
        self.appState = appState
    }
    
    func getTime(_ time: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        let formattedTime = formatter.string(from: time) ?? "00:00"
        return formattedTime
    }
    
    var body: some View {
        HStack {
            Text("\(getTime(audioPlayerService.audioPlayer?.currentTime ?? 0.0))")
                .font(.system(size: 30))
            
            Slider(
                value: $currentTime,
                in: 0...duration,
                onEditingChanged: sliderEditingChanged
            )
            .tint(.teal)
            .onReceive(timer) { _ in
                self.currentTime = audioPlayerService.audioPlayer?.currentTime ?? 0
            }
            .padding()
        
            Text("\(getTime(audioPlayerService.audioPlayer?.duration ?? 0.0))")
                .font(.system(size: 30))
        }.padding(.leading, 30)
        .padding(.trailing, 0)
        
        HStack {
            if recording.name !=  "" {
                if playing {
                    PauseIconView()
                        .onTapGesture {
                            audioPlayerService.pause()
                            playing = false
                            
                            Task {
                                await Event.create(appState: appState, name:
                                                    "RecordingPaused")
                            }
                        }
                } else {
                    PlayIconView()
                        .onTapGesture {
                            print("playing: \(recording.name!) at time \(currentTime)")
                            audioPlayerService.audioPlayer?.currentTime = currentTime
                            audioPlayerService.playRecording(name: recording.name!)
                            playing = true
                            
                            Task {
                                await Event.create(appState: appState, name:
                                                    "RecordingPlayed")
                            }
                        }
                }
            }
        }.offset(y: -30)
    }
    
    
    func seek() {
        currentTime = min(currentTime, duration)
        // Here you would integrate with your audio playback framework to seek.
        
//        let newTime = CMTime(seconds: currentTime, preferredTimescale: 600)
        audioPlayerService.audioPlayer?.currentTime = currentTime
    }
    
    func sliderEditingChanged(editingStarted: Bool) {
        if !editingStarted {
            seek()
        }
    }
}
