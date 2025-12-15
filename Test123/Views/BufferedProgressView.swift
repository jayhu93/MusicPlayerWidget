import SwiftUI

struct BufferedProgressView: View {
  @State private var isDragging = false
  @Binding var currentTime: Double
  let totalTime: Double
  let bufferedTime: Double

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        // Background track (lighter color)
        Capsule()
          .fill(Color.white.opacity(0.2))
          .frame(height: 2.4)

        // Buffered progress (light color)
        Capsule()
          .fill(Color.white.opacity(0.5))
          .frame(width: bufferedProgress(width: geometry.size.width), height: 2)

        // Current playback progress
        Capsule()
          .fill(Constants.BaselinePrimaryColorsOnPrimary)
          .frame(width: currentProgress(width: geometry.size.width), height: 3.17)

        // Draggable thumb
        Circle()
          .fill(Constants.BaselinePrimaryColorsOnPrimary)
          .frame(width: 12, height: 12)
          .offset(x: currentProgress(width: geometry.size.width) - 7)
          .gesture(
            DragGesture(minimumDistance: 0)
              .onChanged { value in
                isDragging = true
                updateTime(from: value, width: geometry.size.width)
              }
              .onEnded { _ in
                isDragging = false
              }
          )
      }
      .frame(height: 12)
    }
    .frame(height: 12)
  }

  private func currentProgress(width: CGFloat) -> CGFloat {
    guard totalTime > 0 else { return 0 }
    let progress = CGFloat(currentTime / totalTime)
    return min(max(0, progress * width), width)
  }

  private func bufferedProgress(width: CGFloat) -> CGFloat {
    guard totalTime > 0 else { return 0 }
    let progress = CGFloat(bufferedTime / totalTime)
    return min(max(0, progress * width), width)
  }

  private func updateTime(from value: DragGesture.Value, width: CGFloat) {
    guard width > 0 else { return }
    let newTime = min(max(0, value.location.x / width * totalTime), totalTime)
    currentTime = newTime
  }
}
