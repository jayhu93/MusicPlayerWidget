import SwiftUI
import Foundation
import Combine

@MainActor @Observable final class MusicPlayerModel {
  private let audioService = AudioService()
  private var cancellables = Set<AnyCancellable>()
  
  var tracks: [Track] = TrackLibrary.createSampleTracks()
  var currentTrackIndex: Int = 0
  var isRepeatEnabled: Bool = false
  
  // Computed properties that sync with AudioManager
  var isPlaying: Bool {
    audioService.isPlaying
  }
  
  var currentTime: Double {
    get { audioService.currentTime }
    set { audioService.seek(to: newValue) }
  }
  
  var totalTime: Double {
    audioService.duration > 0 ? audioService.duration : 0
  }
  
  var bufferedTime: Double {
    audioService.bufferedTime
  }
  
  // Current track info
  var currentTrack: Track? {
    guard currentTrackIndex < tracks.count else { return nil }
    return tracks[currentTrackIndex]
  }
  
  var songTitle: String {
    currentTrack?.title ?? "No Track"
  }
  
  var artistInfo: String {
    currentTrack?.artist ?? "Unknown Artist"
  }
  
  var isFavorite: Bool {
    get { currentTrack?.isFavorite ?? false }
    set {
      if let track = currentTrack {
        track.isFavorite = newValue
      }
    }
  }
  
  var albumImageURL: String? {
    currentTrack?.albumImageURL
  }
  
  // Navigation boundary checks
  var canGoToPrevious: Bool {
    isRepeatEnabled || currentTrackIndex > 0
  }
  
  var canGoToNext: Bool {
    isRepeatEnabled || currentTrackIndex < tracks.count - 1
  }
  
  // Computed property for formatted current time
  var formattedCurrentTime: String {
    formatTime(currentTime)
  }
  
  // Computed property for formatted total time
  var formattedTotalTime: String {
    formatTime(totalTime)
  }
  
  init() {
    loadCurrentTrack()
  }
  
  func loadCurrentTrack() {
    guard let track = currentTrack else { return }
    audioService.loadAudio(from: track.audioURL)
  }
  
  // Actions
  func togglePlayPause() {
    audioService.togglePlayPause()
  }
  
  func toggleFavorite() {
    guard let track = currentTrack else { return }
    
    // Optimistically update UI immediately
    track.isFavorite.toggle()
  }
  
  func skipToPrevious() {
    if isRepeatEnabled {
      // Cycle: if at first track, go to last
      currentTrackIndex = currentTrackIndex > 0 ? currentTrackIndex - 1 : tracks.count - 1
    } else {
      // Normal: only go back if not at first track
      if currentTrackIndex > 0 {
        currentTrackIndex -= 1
      }
    }
    switchToCurrentTrack()
  }
  
  func skipToNext() {
    if isRepeatEnabled {
      // Cycle: if at last track, go to first
      currentTrackIndex = currentTrackIndex < tracks.count - 1 ? currentTrackIndex + 1 : 0
    } else {
      // Normal: only go forward if not at last track
      if currentTrackIndex < tracks.count - 1 {
        currentTrackIndex += 1
      }
    }
    switchToCurrentTrack()
  }
  
  private func switchToCurrentTrack() {
    guard let track = currentTrack else { return }
    Task {
      await audioService.switchTrack(to: track.audioURL)
      // Auto-play the new track
      audioService.play()
    }
  }
  
  func toggleRepeat() {
    isRepeatEnabled.toggle()
  }
  
  // Helper function to format time
  private func formatTime(_ seconds: Double) -> String {
    let minutes = Int(seconds) / 60
    let remainingSeconds = Int(seconds) % 60
    return String(format: "%d:%02d", minutes, remainingSeconds)
  }
}
