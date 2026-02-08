//
//  RecordingsListView.swift
//  MediaManagementApp
//
//  Created by Nar Rasaily on 2/8/26.
//
import SwiftUI

/// List of all saved recordings
struct RecordingsListView: View {
    @ObservedObject var audioManager: AudioManager
    
    var body: some View {
        Group {
            if audioManager.recordings.isEmpty {
                EmptyRecordingsView()
            } else {
                List {
                    ForEach(audioManager.recordings) { memo in
                        RecordingRow(
                            memo: memo,
                            isPlaying: audioManager.currentlyPlaying == memo.url,
                            onPlay: { audioManager.play(memo: memo) },
                            onStop: { audioManager.stop() }
                        )
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            audioManager.deleteRecording(audioManager.recordings[index])
                        }
                    }
                }
                .listStyle(.carousel)
            }
        }
        .navigationTitle("Recordings")
    }
}

/// Single recording row
struct RecordingRow: View {
    let memo: VoiceMemo
    let isPlaying: Bool
    let onPlay: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        Button(action: {
            if isPlaying {
                onStop()
            } else {
                onPlay()
            }
        }) {
            HStack(spacing: 12) {
                // Play/Stop icon
                ZStack {
                    Circle()
                        .fill(isPlaying ? Color.orange : Color.blue)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                }
                
                // Memo info
                VStack(alignment: .leading, spacing: 2) {
                    Text(memo.dateString)
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 8) {
                        Label(memo.durationString, systemImage: "clock")
                        Label(memo.fileSize, systemImage: "doc")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Playing indicator
                if isPlaying {
                    Image(systemName: "waveform")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

/// Empty state view
struct EmptyRecordingsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "waveform.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            
            Text("No Recordings")
                .font(.headline)
            
            Text("Tap Record to create your first voice memo")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    RecordingsListView(audioManager: AudioManager())
}


