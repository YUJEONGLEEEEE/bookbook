import UIKit
import SnapKit
import SwiftUI

final class LoadingManager {
    static let shared = LoadingManager()

    private var dimView: UIView?
    private var loadingCount = 0

    private init() {}

    // MARK: - Show
    func showLoading(on view: UIView) {
        DispatchQueue.main.async {
            self.loadingCount += 1

            // 이미 떠있으면 count만 증가
            guard self.dimView == nil else { return }

            let dimView = UIView()
            dimView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
            dimView.alpha = 0

            view.addSubview(dimView)
            dimView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }

            let overlayView = UIView()
            overlayView.backgroundColor = .sub02
            overlayView.layer.cornerRadius = 20

            dimView.addSubview(overlayView)
            overlayView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(120)
            }

            let hosting = UIHostingController(rootView: AnimatedSymbolView())
            hosting.view.backgroundColor = .clear

            overlayView.addSubview(hosting.view)
            hosting.view.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(60)
            }

            UIView.animate(withDuration: 0.25) {
                dimView.alpha = 1
            }

            self.dimView = dimView
        }
    }

    // MARK: - Hide
    func hideLoading() {
        DispatchQueue.main.async {
            self.loadingCount -= 1

            // 여러 API 요청 중이면 유지
            guard self.loadingCount <= 0 else { return }

            guard let dimView = self.dimView else { return }

            UIView.animate(withDuration: 0.25, animations: {
                dimView.alpha = 0
            }) { _ in
                dimView.removeFromSuperview()
            }

            self.dimView = nil
            self.loadingCount = 0
        }
    }
}
