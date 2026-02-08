//
//  ContentView.swift
//  MediaManagementApp Watch App
//
//  Created by Nar Rasaily on 2/8/26.
//

import SwiftUI

/// Main content view with tab navigation
struct ContentView: View {
    @StateObject private var audioManager = AudioManager()
    
    var body: some View {
        TabView {
            // Recording View
            RecordingView(audioManager: audioManager)
                .tag(0)
            
            // Recordings List
            RecordingsListView(audioManager: audioManager)
                .tag(1)
        }
        .tabViewStyle(.verticalPage)
        .onDisappear {
            // Stop any playback when leaving
            audioManager.stop()
        }
    }
}

#Preview {
    ContentView()
}
