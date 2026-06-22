import UIKit
import SnapKit

// 로딩 스피너(UIKit 네이티브).
// iOS 26+: scribble을 써내려갔다(drawOn) 지우는(drawOff) "그리기" 동작을 반복.
// 그 미만(iOS 17~25): variableColor 반복(획이 순차적으로 차오름)으로 폴백.
//
// SwiftUI .symbolEffect(.drawOn)은 UIHostingController 오버레이에서 등장 전환이 트리거되지
// 않아 렌더되지 않으므로, UIKit의 addSymbolEffect(.drawOn)을 직접 사용한다.
//
// 종료 요청(finishGracefully)이 와도 그리는 도중에 뚝 끊지 않고, 진행 중인 획을 완성하거나
// 지우기를 끝낸 "자연스러운 경계"에서 종료한다(중간에 갑자기 사라지는 어색함 방지).
final class DrawingLoadingView: UIView {
    private enum Phase { case idle, drawingOn, drawn, drawingOff, erased }

    private let imageView = UIImageView()
    private var phase: Phase = .idle
    private var running = false
    private var wantsFinish = false
    private var finishCompletion: (() -> Void)?

    private let holdDrawn: TimeInterval = 0.7   // 다 그린 뒤 유지
    private let holdErased: TimeInterval = 0.35 // 다 지운 뒤 대기

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        let config = UIImage.SymbolConfiguration(pointSize: 44, weight: .regular)
        imageView.image = UIImage(systemName: "scribble.variable", withConfiguration: config)
        imageView.tintColor = .customMain
        imageView.contentMode = .center
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func startAnimating() {
        guard !running else { return }
        running = true
        if #available(iOS 26.0, *) {
            beginDrawOn()
        } else {
            imageView.addSymbolEffect(.variableColor.iterative, options: .repeating)
        }
    }

    // 그리기가 안정 상태(완성/지움 완료)에 도달하면 completion 호출 후 정지.
    // 그리는/지우는 중이면 그 애니메이션을 끝낸 뒤 종료한다.
    func finishGracefully(completion: @escaping () -> Void) {
        guard running else { completion(); return }
        guard #available(iOS 26.0, *) else { finish(completion); return } // 폴백은 즉시 종료
        wantsFinish = true
        finishCompletion = completion
        switch phase {
        case .drawn, .erased, .idle:
            finishNow()             // 이미 안정 상태 → 바로 종료(완성된 모습으로 페이드)
        case .drawingOn, .drawingOff:
            break                    // 진행 중 → 애니메이션 완료 콜백에서 종료
        }
        // 안전장치: 콜백이 안 오는 경우 강제 종료
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.finishNow()
        }
    }

    // 즉시 정지(페이드아웃 직후 정리용)
    func stopAnimating() {
        running = false
        wantsFinish = false
        finishCompletion = nil
        imageView.removeAllSymbolEffects()
    }

    @available(iOS 26.0, *)
    private func beginDrawOn() {
        phase = .drawingOn
        imageView.addSymbolEffect(.drawOff, options: .nonRepeating, animated: false) // 미그림 상태로 리셋
        imageView.addSymbolEffect(.drawOn, options: .nonRepeating.speed(0.7), animated: true) { [weak self] _ in
            guard let self, self.running else { return }
            self.phase = .drawn
            if self.wantsFinish { self.finishNow(); return }
            DispatchQueue.main.asyncAfter(deadline: .now() + self.holdDrawn) { [weak self] in
                guard let self, self.running, self.phase == .drawn else { return }
                self.beginDrawOff()
            }
        }
    }

    @available(iOS 26.0, *)
    private func beginDrawOff() {
        phase = .drawingOff
        imageView.addSymbolEffect(.drawOff, options: .nonRepeating.speed(0.7), animated: true) { [weak self] _ in
            guard let self, self.running else { return }
            self.phase = .erased
            if self.wantsFinish { self.finishNow(); return }
            DispatchQueue.main.asyncAfter(deadline: .now() + self.holdErased) { [weak self] in
                guard let self, self.running, self.phase == .erased else { return }
                self.beginDrawOn()
            }
        }
    }

    private func finishNow() {
        guard running else { return }
        finish(finishCompletion)
    }
    private func finish(_ completion: (() -> Void)?) {
        running = false
        wantsFinish = false
        finishCompletion = nil
        completion?()
    }

    deinit { }
}
