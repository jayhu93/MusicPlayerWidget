import Foundation

struct TrackLibrary {
  /// Sample tracks for playback.
  static func createSampleTracks() -> [Track] {
    return [
      Track(
        title: "Midnight Dreams",
        artist: "Luna Eclipse",
        audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
        albumImageURL: "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=400&fit=crop"
      ),
      Track(
        title: "The Long and Winding Road to Nowhere in Particular",
        artist: "The Extraordinarily Talented Orchestra of the Northern Hemisphere",
        audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
        albumImageURL: "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=400&fit=crop"
      ),
      Track(
        title: "Summer Vibes",
        artist: "Beach Boys Revival",
        audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
        albumImageURL: "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&h=400&fit=crop"
      ),
      Track(
        title: "A Symphony of Colors Dancing Through the Moonlit Sky",
        artist: "The International Philharmonic Society of Contemporary Musicians",
        audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3",
        albumImageURL: "https://images.unsplash.com/photo-1514320291840-2e0a9bf2a9ae?w=400&h=400&fit=crop"
      ),
      Track(
        title: "Electric Pulse",
        artist: "DJ Neon",
        audioURL: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3",
        albumImageURL: "https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=400&h=400&fit=crop"
      )
    ]
  }
}
