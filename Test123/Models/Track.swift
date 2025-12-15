import Foundation

/// Used to hold a single track information.
@Observable class Track: Identifiable {
  var id: String
  var title: String
  var artist: String
  var audioURL: String
  var albumImageURL: String?
  var isFavorite: Bool
  
  init(id: String = UUID().uuidString, title: String, artist: String, audioURL: String, albumImageURL: String? = nil, isFavorite: Bool = false) {
    self.id = id
    self.title = title
    self.artist = artist
    self.audioURL = audioURL
    self.albumImageURL = albumImageURL
    self.isFavorite = isFavorite
  }
}
