import SwiftUI

struct MusicPlayerView: View {
  @State var state: MusicPlayerModel
  
  init() {
    self.state = MusicPlayerModel()
  }
  
  var body: some View {
    VStack {
      // Album Art and Song Info
      HStack(alignment: .center, spacing: 16) {
        // Album Art
        AsyncImage(url: state.albumImageURL.flatMap { URL(string: $0) }) { phase in
          switch phase {
          case .empty:
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 88, height: 88)
              .overlay(
                ProgressView()
                  .progressViewStyle(CircularProgressViewStyle(tint: .white))
              )
              .accessibilityLabel("Album artwork loading")
          case .success(let image):
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 88, height: 88)
              .clipped()
              .accessibilityLabel("Album artwork for \(state.songTitle)")
          case .failure:
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 88, height: 88)
              .overlay(
                Image(systemName: "music.note")
                  .foregroundColor(.white.opacity(0.5))
                  .font(.system(size: 32))
              )
              .accessibilityLabel("Album artwork unavailable")
          @unknown default:
            Rectangle()
              .fill(Color.gray.opacity(0.3))
              .frame(width: 88, height: 88)
              .accessibilityLabel("Album artwork unavailable")
          }
        }
        .cornerRadius(4)
        .accessibilityAddTraits(.isImage)
        
        VStack(spacing: 10) {
          // Song Title
          //                Text(state.songTitle)
          //                  .font(
          //                    Font.custom(Constants.FontOpenSansMedium, size: Constants.StaticHeadlineSmallSize)
          //                  )
          //                  .foregroundColor(Constants.BaselinePrimaryColorsOnPrimary)
          //                  .frame(maxWidth: .infinity, alignment: .leading)
          //                  .lineLimit(1) // Comment out for multiline
          //                  .truncationMode(.tail) // Comment out for multiline
          //                  .accessibilityLabel("Track title: \(state.songTitle)")
          //
          //                // Artist Info
          //                Text(state.artistInfo)
          //                  .font(Font.custom(Constants.FontOpenSansRegular, size: Constants.StaticBodyLargeSize))
          //                  .foregroundColor(Constants.BaselinePrimaryColorsOnPrimary)
          //                  .frame(maxWidth: .infinity, alignment: .leading)
          //                  .opacity(0.5)
          //                  .lineLimit(1) // Comment out for multiline
          //                  .truncationMode(.tail) // Comment out for multiline
          //                  .accessibilityLabel("Artist: \(state.artistInfo)")
          
          MarqueeText(
            text: state.songTitle,
            font: .custom(Constants.FontOpenSansMedium, size: Constants.StaticHeadlineSmallSize),
            color: Constants.BaselinePrimaryColorsOnPrimary
          )
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityLabel("Now playing: \(state.songTitle)")
          .accessibilityAddTraits(.isStaticText)
          .id(state.currentTrack?.id ?? "")
          
          MarqueeText(
            text: state.artistInfo,
            font: .custom(Constants.FontOpenSansRegular, size: Constants.StaticBodyLargeSize),
            color: Constants.BaselinePrimaryColorsOnPrimary
          )
          .frame(maxWidth: .infinity, alignment: .leading)
          .accessibilityLabel("Artist: \(state.artistInfo)")
          .accessibilityAddTraits(.isStaticText)
          .id(state.currentTrack?.id ?? "")
        }
      }
      .accessibilityElement(children: .combine)
      .accessibilityLabel("Current track: \(state.songTitle) by \(state.artistInfo)")
      .accessibilityAddTraits(.isStaticText)
      
      Spacer()
        .frame(maxHeight: 35)
      
      // Progress Slider
      VStack(spacing: 6) {
        BufferedProgressView(
          currentTime: $state.currentTime,
          totalTime: state.totalTime,
          bufferedTime: state.bufferedTime
        )
        
        // Time Labels
        HStack {
          Text(state.formattedCurrentTime)
            .font(
              Font.custom(Constants.StaticLabelMediumFont, size: Constants.StaticLabelMediumSize)
                .weight(.medium)
            )
            .kerning(Constants.StaticLabelMediumTracking)
            .foregroundColor(.white.opacity(0.7))
          
          Spacer()
          
          Text(state.formattedTotalTime)
            .font(
              Font.custom(Constants.StaticLabelMediumFont, size: Constants.StaticLabelMediumSize)
                .weight(.medium)
            )
            .kerning(Constants.StaticLabelMediumTracking)
            .foregroundColor(.white.opacity(0.7))
        }
      }
      .accessibilityElement(children: .combine)
      .accessibilityLabel("Playback progress")
      .accessibilityValue("\(state.formattedCurrentTime) of \(state.formattedTotalTime)")
      .accessibilityHint("Swipe up or down to adjust playback position")
      .accessibilityAdjustableAction { direction in
        switch direction {
        case .increment:
          state.currentTime = min(state.currentTime + 10, state.totalTime)
        case .decrement:
          state.currentTime = max(state.currentTime - 10, 0)
        @unknown default:
          break
        }
      }
      
      // Control Buttons
      HStack(spacing: 24) {
        // Repeat Button
        Button(action: {
          state.toggleRepeat()
        }) {
          Image(state.isRepeatEnabled ? "repeat_on" : "repeat")
            .foregroundColor(Constants.BaselineSurfaceColorsInverseOnSurface)
            .frame(width: 36, height: 36, alignment: .center)
        }
        .accessibilityLabel(state.isRepeatEnabled ? "Repeat enabled" : "Repeat disabled")
        .accessibilityHint("Double tap to toggle repeat mode")
        .accessibilityAddTraits(.isButton)
        
        // Previous Button
        Button(action: {
          state.skipToPrevious()
        }) {
          Image("skip_previous")
            .foregroundColor(Constants.BaselineSurfaceColorsInverseOnSurface)
            .frame(width: 36, height: 36, alignment: .center)
        }
        .accessibilityLabel("Previous track")
        .accessibilityHint(state.canGoToPrevious ? "Double tap to play previous track" : "No previous track available")
        .accessibilityAddTraits(.isButton)
        .disabled(!state.canGoToPrevious)
        .opacity(state.canGoToPrevious ? 1.0 : 0.3)
        
        // Play/Pause Button
        Button(action: {
          withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            state.togglePlayPause()
          }
        }) {
          ZStack {
            Circle()
              .fill(Color(red: 0, green: 0.29, blue: 0.47))
              .frame(width: 72, height: 72)
            
            Image(state.isPlaying ? "pause" : "play")
              .foregroundColor(Constants.BaselineSurfaceColorsInverseOnSurface)
              .frame(width: 48, height: 48, alignment: .center)
          }
        }
        .accessibilityLabel(state.isPlaying ? "Pause" : "Play")
        .accessibilityHint(state.isPlaying ? "Double tap to pause" : "Double tap to play")
        .accessibilityAddTraits(.isButton)
        
        // Next Button
        Button(action: {
          state.skipToNext()
        }) {
          Image("next")
            .foregroundColor(Constants.BaselineSurfaceColorsInverseOnSurface)
            .frame(width: 36, height: 36, alignment: .center)
        }
        .accessibilityLabel("Next track")
        .accessibilityHint(state.canGoToNext ? "Double tap to play next track" : "No next track available")
        .accessibilityAddTraits(.isButton)
        .disabled(!state.canGoToNext)
        .opacity(state.canGoToNext ? 1.0 : 0.3)
        
        Button(action: {
          if !state.isFavorite {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
          }
          withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            state.toggleFavorite()
          }
        })  {
          Image("favorite")
            .foregroundColor(state.isFavorite ? Color.red : Constants.BaselineSurfaceColorsInverseOnSurface)
            .frame(width: 36, height: 36, alignment: .center)
        }
        .accessibilityLabel(state.isFavorite ? "Favorited" : "Not favorited")
        .accessibilityHint("Double tap to \(state.isFavorite ? "unfavorite" : "favorite") this track")
        .accessibilityAddTraits(.isButton)
      }
    }
    .padding(32)
    .background(Color(red: 0.18, green: 0.2, blue: 0.25))
    .cornerRadius(16)
  }
}
