//
//  AudioPlayerService.swift
//  SubtitlesIRL
//
//  Created by David on 3/17/24.
//

import Foundation
import AVFoundation

class AudioPlayerService: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    
    func prepareRecording(name: String) {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(name).m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
        } catch {
            print("Could not load file for playback: \(error)")
        }
        
    }
    
    func playRecording(name: String) {
//        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(name).m4a")
        
//        print("attempting to play \(audioFilename)")
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
//        self.prepareRecording(name: name)
        audioPlayer?.play()
//        } catch {
//            print("Could not load file for playback: \(error)")
//        }
    }
    
    func pause() {
        audioPlayer?.pause()
    }
    
    func stop() {
        audioPlayer?.stop()
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func clearAllData() {
        deleteAllFilesInDocumentsFolder()
    }
    func deleteAllFilesInDocumentsFolder() {
        let fileManager = FileManager.default
        // Get the URL for the Documents directory
        let documentsDirectoryURL = getDocumentsDirectory()
        do {
            // List all contents of the Documents directory
            let filePaths = try fileManager.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil, options: [])
            
            // Iterate over each file and delete it
            for filePath in filePaths {
                if filePath.pathExtension.lowercased() == "m4a" {
                    try fileManager.removeItem(at: filePath)
                    print("Deleted file: \(filePath.lastPathComponent)")
                }
            }
        } catch {
            print("Could not clear Documents folder: \(error)")
        }
    }
}
