import SwiftUI

struct AnimatedSymbolView: View {
    var body: some View {
        if #available(iOS 26.0, *) {
            DrawingSymbolView()
        } else {
            PulseSymbolView()
        }
    }
}

// iOS 26+: draw-on / draw-off 효과
@available(iOS 26.0, *)
private struct DrawingSymbolView: View {
    @State private var isDrawn = true

    var body: some View {
        Image(systemName: "scribble.variable")
            .font(.system(size: 44))
            .foregroundStyle(Color(.customMain))
            .symbolEffect(.drawOn, options: .speed(0.5), isActive: isDrawn)
            .symbolEffect(.drawOff, options: .speed(0.5), isActive: !isDrawn)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task {
                while !Task.isCancelled {
                    isDrawn = true
                    try? await Task.sleep(nanoseconds: 2_500_000_000)
                    isDrawn = false
                    try? await Task.sleep(nanoseconds: 900_000_000)
                }
            }
    }
}

// iOS 26 미만 폴백: pulse 효과
private struct PulseSymbolView: View {
    @State private var isAnimating = false

    var body: some View {
        Image(systemName: "scribble.variable")
            .font(.system(size: 44))
            .foregroundColor(Color(.customMain))
            .symbolEffect(.pulse, options: .repeating, isActive: isAnimating)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { isAnimating = true }
    }
}
