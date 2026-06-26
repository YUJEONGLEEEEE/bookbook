import UIKit
import SnapKit

final class DrawingLoadingView: UIView {
    private enum Phase { case idle, drawingOn, drawn, drawingOff, erased }

    private let imageView = UIImageView()
    private var phase: Phase = .idle
    private var running = false
    private var wantsFinish = false
    private var finishCompletion: (() -> Void)?

    private let holdDrawn: TimeInterval = 0.7
    private let holdErased: TimeInterval = 0.35

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

    func finishGracefully(completion: @escaping () -> Void) {
        guard running else { completion(); return }
        guard #available(iOS 26.0, *) else { finish(completion); return }
        wantsFinish = true
        finishCompletion = completion
        switch phase {
        case .drawn, .erased, .idle:
            finishNow()
        case .drawingOn, .drawingOff:
            break
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.finishNow()
        }
    }

    func stopAnimating() {
        running = false
        wantsFinish = false
        finishCompletion = nil
        imageView.removeAllSymbolEffects()
    }

    @available(iOS 26.0, *)
    private func beginDrawOn() {
        phase = .drawingOn
        imageView.addSymbolEffect(.drawOff, options: .nonRepeating, animated: false)
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
