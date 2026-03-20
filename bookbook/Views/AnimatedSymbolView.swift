import SwiftUI

struct AnimatedSymbolView: View {
    @State private var isAnimating = false

    var body: some View {
        Image(systemName: "scribble.variable")
            .font(.system(size: 72))
            .foregroundColor(Color(.customMain))
            .modifier(AnimatedSymbolModifier(isAnimating: isAnimating))
            .onAppear {
                isAnimating = true
            }
    }
}

struct AnimatedSymbolModifier: ViewModifier {
    let isAnimating: Bool

    func body(content: Content) -> some View {

        if #available(iOS 26.0, *) {
            // ✅ iOS 26 이상 → 진짜 “그려지는 효과”
            content
                .symbolEffect(
                    .drawOn,
                    options: .repeating.speed(1.2),
                    isActive: isAnimating
                )

        } else {
            // ✅ iOS 25 이하 → 유사한 느낌 직접 구현
            content
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .scaleEffect(isAnimating ? 1.1 : 0.9)
                .opacity(isAnimating ? 1 : 0.6)
                .animation(
                    .easeInOut(duration: 0.8)
                    .repeatForever(autoreverses: true),
                    value: isAnimating
                )
        }
    }
}
