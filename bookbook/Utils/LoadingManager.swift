import UIKit
import SnapKit
import SwiftUI

final class LoadingManager {
    static let shared = LoadingManager()

    private var dimView: UIView?
    // UIHostingController는 반드시 retain (안 하면 SwiftUI 렌더링 끊김)
    private var hostingController: UIHostingController<AnimatedSymbolView>?
    private var loadingCount = 0

    private init() {}

    // MARK: - Show
    func showLoading(on view: UIView) {
        DispatchQueue.main.async {
            self.loadingCount += 1
            // 이미 떠 있으면 재사용
            if let dim = self.dimView, dim.window != nil { return }
            // stuck 오버레이 정리 후 새로 표시
            self.cleanupOverlay()
            self.presentOverlay(on: view)
        }
    }

    // MARK: - Hide
    func hideLoading() {
        DispatchQueue.main.async {
            self.loadingCount = max(0, self.loadingCount - 1)   // 음수로 꼬이지 않게 clamp
            guard self.loadingCount == 0 else { return }
            self.dismissOverlay()
        }
    }

    // MARK: - Private

    private func presentOverlay(on view: UIView) {
        let dimView = UIView()
        dimView.backgroundColor = .clear
        dimView.alpha = 0
        view.addSubview(dimView)
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let hosting = UIHostingController(rootView: AnimatedSymbolView())
        hosting.view.backgroundColor = .clear
        let parentVC = owningViewController(of: view)
        parentVC?.addChild(hosting)
        dimView.addSubview(hosting.view)
        hosting.view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(80)
        }
        if let parentVC { hosting.didMove(toParent: parentVC) }

        UIView.animate(withDuration: 0.25) { dimView.alpha = 1 }
        self.dimView = dimView
        self.hostingController = hosting
    }

    private func dismissOverlay() {
        guard let dimView = self.dimView else { return }
        let hosting = self.hostingController
        self.dimView = nil
        self.hostingController = nil
        UIView.animate(withDuration: 0.25, animations: {
            dimView.alpha = 0
        }) { _ in
            hosting?.willMove(toParent: nil)
            hosting?.view.removeFromSuperview()
            hosting?.removeFromParent()
            dimView.removeFromSuperview()
        }
    }

    // 즉시(애니메이션 없이) 정리 — stuck 오버레이 제거용
    private func cleanupOverlay() {
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()
        dimView?.removeFromSuperview()
        dimView = nil
        hostingController = nil
    }

    // 뷰가 속한 뷰컨트롤러를 responder chain으로 탐색
    private func owningViewController(of view: UIView) -> UIViewController? {
        var responder: UIResponder? = view
        while let current = responder {
            if let vc = current as? UIViewController { return vc }
            responder = current.next
        }
        return nil
    }
}
