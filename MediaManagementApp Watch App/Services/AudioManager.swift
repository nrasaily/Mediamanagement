//
//  AudioManager.swift
//  MediaManagementApp
//
//  Created by Nar Rasaily on 2/8/26.
//
import Foundation
import AVFoundation
import WatchKit
import Combine

/// Manages audio recording and playback
class AudioManager: NSObject, ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingTime: TimeInterval = 0
    @Published var recordings: [VoiceMemo] = []
    @Published var currentlyPlaying: URL?
    @Published var hasPermission = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    
    private let recordingSettings: [String: Any] = [
        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
        AVSampleRateKey: 44100,
        AVNumberOfChannelsKey: 1,
        AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
    ]
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        loadRecordings()
    }
    
    // MARK: - Permission
    
    func requestPermission() async {
        hasPermission = await AVAudioApplication.requestRecordPermission()
    }
    
    // MARK: - Recording
    
    func startRecording() {
        guard hasPermission else {
            errorMessage = "Microphone permission required"
            return
        }
        
        let filename = "memo_\(Int(Date().timeIntervalSince1970)).m4a"
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)
            
            audioRecorder = try AVAudioRecorder(url: url, settings: recordingSettings)
            audioRecorder?.record()
            
            isRecording = true
            recordingTime = 0
            startTimer()
            
            WKInterfaceDevice.current().play(.start)
        } catch {
            errorMessage = "Recording failed: \(error.localizedDescription)"
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        stopTimer()
        isRecording = false
        
        // Add new recording to list
        if let url = audioRecorder?.url {
            let memo = VoiceMemo(
                url: url,
                createdAt: Date(),
                duration: recordingTime
            )
            recordings.insert(memo, at: 0)
        }
        
        audioRecorder = nil
        WKInterfaceDevice.current().play(.stop)
    }
    
    // MARK: - Playback
    
    func play(memo: VoiceMemo) {
        // Stop any current playback
        stop()
        
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: memo.url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            isPlaying = true
            currentlyPlaying = memo.url
            
            WKInterfaceDevice.current().play(.click)
        } catch {
            errorMessage = "Playback failed: \(error.localizedDescription)"
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentlyPlaying = nil
    }
    
    // MARK: - File Management
    
    func deleteRecording(_ memo: VoiceMemo) {
        do {
            try FileManager.default.removeItem(at: memo.url)
            recordings.removeAll { $0.url == memo.url }
            WKInterfaceDevice.current().play(.click)
        } catch {
            errorMessage = "Delete failed: \(error.localizedDescription)"
        }
    }
    
    func loadRecordings() {
        let documentsURL = getDocumentsDirectory()
        
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: documentsURL,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )
            
            recordings = files
                .filter { $0.pathExtension == "m4a" }
                .compactMap { url -> VoiceMemo? in
                    let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                    let createdAt = attributes?[.creationDate] as? Date ?? Date()
                    
                    // Get duration
                    let asset = AVURLAsset(url: url)
                    let duration = CMTimeGetSeconds(asset.duration)
                    
                    return VoiceMemo(url: url, createdAt: createdAt, duration: duration)
                }
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            errorMessage = "Failed to load recordings"
        }
    }
    
    // MARK: - Helpers
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func startTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordingTime += 1
        }
    }
    
    private func stopTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentlyPlaying = nil
        }
    }
}


