//
//  VoiceMemo.swift
//  MediaManagementApp
//
//  Created by Nar Rasaily on 2/8/26.
//
import Foundation

/// Represents a saved voice memo recording
struct VoiceMemo: Identifiable {
    let id = UUID()
    let url: URL
    let createdAt: Date
    let duration: TimeInterval
    
    /// Filename without extension
    var name: String {
        url.deletingPathExtension().lastPathComponent
    }
    
    /// Formatted creation date
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
    
    /// Formatted duration (mm:ss)
    var durationString: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// File size in KB
    var fileSize: String {
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        let size = attributes?[.size] as? Int64 ?? 0
        return "\(size / 1024) KB"
    }
}


