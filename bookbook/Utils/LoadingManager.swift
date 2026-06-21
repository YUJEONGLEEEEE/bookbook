import UIKit
import SnapKit
import SwiftUI

final class LoadingManager {
    static let shared = LoadingManager()

    private var dimView: UIView?
    // UIHostingController는 반드시 retain (안 하면 SwiftUI 렌더링 끊김)
    private var hostingController: UIHostingController<AnimatedSymbolView>?
    private var loadingCount = 0

    // 응답이 이 시간보다 오래 걸릴 때만 스피너를 띄운다.
    // 캐시 적중 등 빠른 응답에서 스피너가 깜빡이는 것을 막기 위한 임계시간.
    private let showDelay: TimeInterval = 0.4
    // 표시 예약(임계시간 대기) 작업 — 그 전에 끝나면 취소되어 스피너가 안 뜬다.
    private var pendingShow: DispatchWorkItem?
    // 스피너를 띄울 대상 화면(항상 최신 요청 기준) — 홈→상세 전환 시 상세에 뜨도록.
    private weak var pendingView: UIView?

    private init() {}

    // MARK: - Show
    func showLoading(on view: UIView) {
        DispatchQueue.main.async {
            self.loadingCount += 1
            self.pendingView = view   // 항상 가장 최근 요청 화면을 대상으로
            // 바로 그 화면에 이미 떠 있으면 재사용
            if let dim = self.dimView, dim.window != nil, dim.superview === view { return }
            // 다른/사라진 화면(예: 가려진 홈)에 남아있던 오버레이는 정리하고 새 화면에 다시 표시
            if self.dimView != nil { self.cleanupOverlay() }
            // 이미 표시가 예약돼 있으면 중복 예약하지 않음(대상은 pendingView로 최신화됨)
            guard self.pendingShow == nil else { return }

            // 임계시간(showDelay) 뒤에도 여전히 로딩 중이면 그때 스피너 표시
            let work = DispatchWorkItem { [weak self] in
                guard let self = self else { return }
                self.pendingShow = nil
                // 대기 중 로딩이 끝났거나(count == 0) 대상 화면이 사라졌으면 표시하지 않음
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
            self.loadingCount = max(0, self.loadingCount - 1)   // 음수로 꼬이지 않게 clamp
            guard self.loadingCount == 0 else { return }
            // 임계시간 전에 끝난 경우: 표시 예약을 취소 → 스피너가 아예 안 뜸(깜빡임 방지)
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
