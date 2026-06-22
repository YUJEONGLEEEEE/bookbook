import SwiftUI

// 로딩 스피너 심볼. .pulse(반복)는 심볼을 항상 표시한 채 투명도만 변화시켜 안정적으로 보인다.
// (이전 iOS 26 전용 .drawOn/.drawOff 조합은 심볼이 "안 그려진" 투명 상태로 머무는 문제가 있었음)
struct AnimatedSymbolView: View {
    @State private var isAnimating = false

    var body: some View {
        // resizable + scaledToFit: 폰트 baseline이 아닌 심볼 아트워크 바운딩 박스 기준으로
        // 렌더링되어 ZStack 중앙에 시각적으로 정확히 정렬된다.
        ZStack {
            Image(systemName: "scribble.variable")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(.customMain))
                .symbolEffect(.pulse, options: .repeating, isActive: isAnimating)
                .frame(width: 48, height: 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .onAppear { isAnimating = true }
    }
}
