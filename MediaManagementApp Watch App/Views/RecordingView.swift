//
//  RecordingView.swift
//  MediaManagementApp
//
//  Created by Nar Rasaily on 2/8/26.
//
import SwiftUI

/// Main recording interface
struct RecordingView: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Recording indicator
            RecordingIndicator(
                isRecording: audioManager.isRecording,
                time: audioManager.recordingTime
            )
            
            // Record button
            RecordButton(
                isRecording: audioManager.isRecording,
                onTap: {
                    if audioManager.isRecording {
                        audioManager.stopRecording()
                    } else {
                        audioManager.startRecording()
                    }
                }
            )
            
            // Permission warning
            if !audioManager.hasPermission {
                Text("Microphone access required")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
            
            // Recording count
            Text("\(audioManager.recordings.count) recordings")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .navigationTitle("Record")
        .task {
            await audioManager.requestPermission()
        }
    }
}

/// Visual recording indicator with timer
struct RecordingIndicator: View {
    let isRecording: Bool
    let time: TimeInterval
    
    @State private var isPulsing = false
    
    private var timeString: String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isRecording ? Color.red.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isPulsing && isRecording ? 1.2 : 1.0)
                
                Image(systemName: isRecording ? "waveform" : "mic.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(isRecording ? .red : .gray)
            }
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
            
            if isRecording {
                Text(timeString)
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(.red)
            }
        }
        .onAppear { isPulsing = true }
    }
}

/// Large record button
struct RecordButton: View {
    let isRecording: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(isRecording ? .red : .white)
                    .frame(width: 60, height: 60)
                
                if isRecording {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.white)
                        .frame(width: 20, height: 20)
                } else {
                    Circle()
                        .fill(.red)
                        .frame(width: 50, height: 50)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    RecordingView(audioManager: AudioManager())
}

