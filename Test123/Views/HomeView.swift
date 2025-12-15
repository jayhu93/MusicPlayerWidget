import SwiftUI

struct HomeView: View {
  var body: some View {
    VStack {
      Text("Welcome to My App!")
        .font(.custom(Constants.FontOpenSansMedium, size: Constants.StaticHeadlineSmallSize))
      // TODO: Styles for player: Large, Regular, Small, Mini, etc.
      MusicPlayerView()
        .frame(maxWidth: 480, maxHeight: 297)
        .padding(.horizontal, 12)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Music Player Widget")
      Spacer()
    }
  }
}

#Preview {
  HomeView()
}
