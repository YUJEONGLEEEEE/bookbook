import UIKit
import SnapKit

final class LoadingManager {
    static let shared = LoadingManager()

    private var dimView: UIView?
    private var loadingView: DrawingLoadingView?
    private var loadingCount = 0

    private let showDelay: TimeInterval = 0.4
    private var pendingShow: DispatchWorkItem?
    private weak var pendingView: UIView?

    private init() {}

    // MARK: - Show
    func showLoading(on view: UIView) {
        DispatchQueue.main.async {
            self.loadingCount += 1
            self.pendingView = view
            if let dim = self.dimView, dim.window != nil, dim.superview === view { return }
            if self.dimView != nil { self.cleanupOverlay() }
            guard self.pendingShow == nil else { return }

            let work = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.pendingShow = nil
                guard self.loadingCount > 0, let target = self.pendingView, target.window != nil else { return }
                debugLog("⏳ 로딩 스피너 표시 — 응답이 \(self.showDelay)s 초과")
                self.cleanupOverlay()
                self.presentOverlay(on: target)
            }
            self.pendingShow = work
            DispatchQueue.main.asyncAfter(deadline: .now() + self.showDelay, execute: work)
        }
    }

    // MARK: - Hide
    func hideLoading() {
        DispatchQueue.main.async {
            self.loadingCount = max(0, self.loadingCount - 1)
            guard self.loadingCount == 0 else { return }
            if self.pendingShow != nil {
                debugLog("⚡️ 빠른 응답(\(self.showDelay)s 이내) — 스피너 생략")
            }
            self.pendingShow?.cancel()
            self.pendingShow = nil
            self.pendingView = nil
            self.dismissOverlay()
        }
    }

    // MARK: - Private

    private func presentOverlay(on view: UIView) {
        let dimView = UIView()
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        dimView.alpha = 0
        view.addSubview(dimView)
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let loading = DrawingLoadingView()
        loading.backgroundColor = .clear
        dimView.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
        }
        loading.startAnimating()

        UIView.animate(withDuration: 0.25) { dimView.alpha = 1 }
        self.dimView = dimView
        self.loadingView = loading
    }

    private func dismissOverlay() {
        guard let dimView = self.dimView else { return }
        let loading = self.loadingView
        self.dimView = nil
        self.loadingView = nil

        let fadeOut = {
            UIView.animate(withDuration: 0.25, animations: {
                dimView.alpha = 0
            }) { _ in
                loading?.stopAnimating()
                loading?.removeFromSuperview()
                dimView.removeFromSuperview()
            }
        }
        if let loading {
            loading.finishGracefully { fadeOut() }
        } else {
            fadeOut()
        }
    }

    private func cleanupOverlay() {
        loadingView?.stopAnimating()
        loadingView?.removeFromSuperview()
        dimView?.removeFromSuperview()
        dimView = nil
        loadingView = nil
    }
}
