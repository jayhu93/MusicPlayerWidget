import SwiftUI

struct MarqueeText: View {
  let text: String
  let font: Font
  let color: Color
  
  @State private var animate = false
  @State private var textWidth: CGFloat = 0
  @State private var containerWidth: CGFloat = 0
  @State private var textHeight: CGFloat = 0
  @Environment(\.sizeCategory) var sizeCategory

  var needsScrolling: Bool {
    textWidth > containerWidth && containerWidth > 0
  }

  var maxOffset: CGFloat {
    // Calculate how far the text can move to the left
    max(0, textWidth - containerWidth)
  }

  var body: some View {
    GeometryReader { geometry in
      HStack(spacing: 0) {
        if needsScrolling {
          // Bouncing text - single instance that moves left and right
          Text(text)
            .font(font)
            .foregroundColor(color)
            .fixedSize()
            .offset(x: animate ? -maxOffset : 0)
            .animation(
              .linear(duration: 10.0)
              .repeatForever(autoreverses: true),
              value: animate
            )
            .onAppear {
              startAnimation()
            }
        } else {
          // Static left-aligned text
          Text(text)
            .font(font)
            .foregroundColor(color)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .frame(width: geometry.size.width, alignment: .leading)
      .clipped()
      .background(
        // Measure text width and height
        Text(text)
          .font(font)
          .fixedSize()
          .hidden()
          .background(
            GeometryReader { textGeometry in
              Color.clear
                .onAppear {
                  updateMeasurements(textGeometry: textGeometry, containerGeometry: geometry)
                }
                .onChange(of: text) { _, _ in
                  updateMeasurements(textGeometry: textGeometry, containerGeometry: geometry)
                  restartAnimation()
                }
                .onChange(of: sizeCategory) { _, _ in
                  // Recalculate when text size changes
                  DispatchQueue.main.async {
                    updateMeasurements(textGeometry: textGeometry, containerGeometry: geometry)
                    restartAnimation()
                  }
                }
                .onChange(of: geometry.size.width) { _, _ in
                  updateMeasurements(textGeometry: textGeometry, containerGeometry: geometry)
                  restartAnimation()
                }
            }
          )
      )
    }
    .frame(height: textHeight > 0 ? textHeight : nil)
  }

  private func updateMeasurements(textGeometry: GeometryProxy, containerGeometry: GeometryProxy) {
    textWidth = textGeometry.size.width
    containerWidth = containerGeometry.size.width
    textHeight = textGeometry.size.height
  }

  private func startAnimation() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      animate = true
    }
  }

  private func restartAnimation() {
    animate = false
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      animate = true
    }
  }
}
