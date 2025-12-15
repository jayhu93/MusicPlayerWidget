import AVFoundation
import Combine

// TODO: Create Protocol, Implementation, and Fake implementation for testing.
@Observable class AudioService {
  private var player: AVPlayer
  private var timeObserver: Any?
  private var cancellables = Set<AnyCancellable>()
  
  var isPlaying: Bool = false
  var currentTime: Double = 0
  var duration: Double = 0
  var bufferedTime: Double = 0
  
  init() {
    self.player = AVPlayer()
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("\(error)")
    }
  }
  
  deinit {
    if let observer = timeObserver {
      player.removeTimeObserver(observer)
    }
  }
  
  public func loadAudio(from url: String) {
    // TODO: Better error handling.
    guard let url = URL(string: url) else {
      return
    }
    let playerItem = AVPlayerItem(url: url)
    self.player.replaceCurrentItem(with: playerItem)
    
    // Observe duration
    NotificationCenter.default.addObserver(
      forName: .AVPlayerItemDidPlayToEndTime,
      object: playerItem,
      queue: .main
    ) { [weak self] _ in
      self?.isPlaying = false
      self?.currentTime = 0
      self?.player.seek(to: .zero)
    }
    
    // Add time observer
    let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
      self?.currentTime = time.seconds
    }
    
    // Observe duration when ready
    playerItem.publisher(for: \.status)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] status in
        switch status {
        case .failed:
          self?.isPlaying = false
        case .readyToPlay:
          let durationSeconds = playerItem.duration.seconds
          if durationSeconds.isFinite && durationSeconds > 0 {
            self?.duration = durationSeconds
          }
        case .unknown:
          break
        @unknown default:
          break
        }
      }
      .store(in: &cancellables)
    
    // Observe buffered time ranges
    playerItem.publisher(for: \.loadedTimeRanges)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] timeRanges in
        guard let timeRange = timeRanges.first?.timeRangeValue else { return }
        let bufferedSeconds = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration)
        self?.bufferedTime = bufferedSeconds
      }
      .store(in: &cancellables)
  }
  
  func play() {
    player.play()
    isPlaying = true
  }
  
  func pause() {
    player.pause()
    isPlaying = false
  }
  
  func togglePlayPause() {
    if isPlaying {
      pause()
    } else {
      play()
    }
  }
  
  func seek(to time: Double) {
    let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
    player.seek(to: cmTime)
    currentTime = time
  }
  
  func switchTrack(to urlString: String) async {
    // Clean up current player
    if let observer = timeObserver {
      player.removeTimeObserver(observer)
      timeObserver = nil
    }
    
    // Reset state
    isPlaying = false
    currentTime = 0
    duration = 0
    
    loadAudio(from: urlString)
  }
}
