//
//  SpeechRecognizerService.swift
//  SubtitlesIRL
//
//  Created by David on 3/17/24.
//
import Foundation
import Speech
import AVFoundation
import CoreData
import UIKit

struct Segment: Identifiable {
    var id: UUID?
    var text: String
    var date: Date
}

class SpeechRecognizerService: NSObject, SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: Locale.current.identifier))!
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    var audioFile: AVAudioFile?
    var audioFilename: String?
    var audioPlayer: AVAudioPlayer?
    var appState: AppState?
    var date: Date = Date()
    private var segments: [Segment] = []
    private var formattedString: String = ""
        
    override init() {
        super.init()
        speechRecognizer.delegate = self
    }    
    
    // Helper function to get the path to the documents directory
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func getRecordingName() -> String {
        let currentDate = Date()
        self.date = currentDate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let formattedDate = formatter.string(from: currentDate)
        return formattedDate
    }
    
    func getAudioURL() -> URL {
        if self.audioFilename == nil {
            self.audioFilename = getRecordingName()
        }
        let audioURL = getDocumentsDirectory().appendingPathComponent("\( self.audioFilename ?? "audioFile").m4a")
        return audioURL
    }
    
    
    func prepareAudioFileForRecording() {
        print("Getting audioURL")
        let audioURL = getAudioURL()
        print("Creating settings")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioFile = try AVAudioFile(forWriting: audioURL, settings: settings)
        } catch {
            print("Failed to create audio file for recording: \(error)")
        }
    }
    
    func prepareAudioPlayer() {
        print("Preparing to play: \(self.audioFilename ?? "audioFile")")
        let audioURL = getAudioURL()
        print("Absolute URL: \(audioURL.absoluteString)")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay() // Preloads audio data into buffers; optional but can reduce latency
        } catch {
            print("Could not load file for playback: \(error)")
        }
    }
    
    func startRecording() throws {
        print("Starting recording")
        // Check if recognitionTask is running, if so, stop it
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        print("Preparing AudioSession")
        // Configure the audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            print("Setting category")
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.allowBluetooth])
            print("Checking to see if InputGainIsSettable")
            if audioSession.isInputGainSettable {
                print("Setting to maxGain")
                try audioSession.setInputGain(1.0) // Max gain
            }
            print("Setting audioSession to active")
            
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to create audio session: \(error)")
        }
        
        // Create a recognitionRequest
        print("Creating recognitionRequest")
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest = recognitionRequest
        recognitionRequest.shouldReportPartialResults = true
        
        // Get the input node from the audio engine
        let inputNode = audioEngine.inputNode
        
        // Start the recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [self] result, error in
            var isFinal = false
            
            if let result = result {
                // Update your UI with the results here
                print("RecognitionRequest Formatted: \(result.bestTranscription.formattedString)")
                
                let formattedString = result.bestTranscription.formattedString
                let spl = formattedString.split(separator: " ")
                var index: Int = 0
                spl.forEach { word in
                    if segments.count <= index {
//                        print("Appending segment: \(String(word))")
                        segments.append(Segment(
                            id: UUID(),
                            text: String(word), date: Date()))
                    } else if segments[index].text != word {
                        // sometimes the text gets fixed
                        segments[index].text = String(word)
                    }
                    index += 1
                }
                
                let customTranscription = segments
                 .filter { segment in
//                     print("segment: \(segment.text) \(segment.date) \(segment.date.timeIntervalSinceNow) \(currentTime)")
                     return segment.date.timeIntervalSinceNow > -10
                 }
                 .map { $0.text }
                 .suffix(15)
                 .joined(separator: " ")
                
                appState?.subtitle = customTranscription
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                // Stop the audio engine and recognition task if there's an error or the result is final
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        print("Preparing file for recording")
        prepareAudioFileForRecording()
        // Configure the audio input node to send audio to the recognition request
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        print("Installing Tap")
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            do {
//                print("Writing data from buffer to audioFile")
                try self.audioFile?.write(from: buffer)
            } catch {
                print("Failed to write audio data to file: \(error)")
            }
//            print("Appending buffer to recognitionRequest")
            recognitionRequest.append(buffer)
        }
        
        do {
            // Start the audio engine
            print("Preparing audio engine")
            audioEngine.prepare()
            print("Starting audio engine")
            try audioEngine.start()
        } catch {
            print("Failed to start audioEngine: \(error)")
        }
        
        // Indicate that recording and recognition have started
        print("Recording and recognizing...")
    }
    
    func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioEngine.inputNode.removeTap(onBus: 0)
        self.audioFile = nil
//        playAudio()
        saveRecordingToCoreData()
        updateAppState()
//        fetchRecordings()
        appState?.subtitle = ""
        self.audioFilename = nil
        self.segments = []
    }
    
    func playAudio() {
        print("Attempting to play audio")
        prepareAudioPlayer()
        if let player = audioPlayer, player.prepareToPlay() {
            player.play()
        }
    }
    
    func saveRecordingToCoreData() {
        print("Saving to core data")
        let managedContext = CoreDataManager.shared.viewContext
        
        // Create a new Recording object
        let newRecording = RecordingModel(context: managedContext)
        newRecording.id = UUID()
        newRecording.name = audioFilename ?? "audioFile"
        newRecording.transcript = segments.map { segment in
            return segment.text
        }.joined(separator: " ")
        newRecording.date = self.date
        
        var startTime: Date? = nil
        var lastTime: Date? = nil
        var lines: [Date: String] = [:]
        var currentLine: String = ""
        segments.forEach { segment in
            let date = segment.date
            
            if startTime == nil {
                // This is the start of a new line
                startTime = date
                currentLine = segment.text
            } else if let lastTime = lastTime, date.timeIntervalSince(lastTime) < 3 {
                // If the current segment is within 3 seconds of the last, add it to the current line
                currentLine += " \(segment.text)"
            } else {
                // More than 3 seconds passed, save the current line and start a new one
                if let startTime = startTime {
                    lines[startTime] = currentLine
                }
                startTime = date
                currentLine = segment.text
            }
            lastTime = date
        }

        // Don't forget to add the last line if it wasn't added already
        if let startTime = startTime, !currentLine.isEmpty {
            lines[startTime] = currentLine
        }
        
        for (date, string) in lines {
            let subtitle = SubtitleModel(context: managedContext)
            subtitle.id = UUID()
            subtitle.text = string
            subtitle.date = date
            newRecording.addToSubtitles(subtitle)
        }
    
        // Attempt to save the new recording
        do {
            print("Saving to managedContext")
            try managedContext.save()
            print("Recording saved to CoreData successfully.")
        } catch let error as NSError {
            print("Could not save the recording. \(error), \(error.userInfo)")
        }
    }
    
    func updateAppState() {
        appState?.recordingsCount = countRecordings()
    }
    
    func countRecordings() -> Int {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecordingModel")
        do {
            let context = CoreDataManager.shared.viewContext
            let count = try context.count(for: fetchRequest)
            if count == NSNotFound {
                // Handle the error - the count could not be determined
                return 0
            }
            return count
        } catch let error as NSError {
            // Handle the error
            print("Could not fetch count for Recordings: \(error), \(error.userInfo)")
            return 0
        }
    }
}

