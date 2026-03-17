
import UIKit
import SnapKit

final class LoadingManager {
    static let shared = LoadingManager()

    private var loadingView: UIView?
    private var activityIndicator: UIActivityIndicatorView!

    private init() {}

    func showLoading(on view: UIView) {
        DispatchQueue.main.async {
            guard self.loadingView == nil else { return }

            let overlayView = UIView()
            overlayView.backgroundColor = .sub02
            overlayView.layer.cornerRadius = 16
            overlayView.alpha = 0

            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .customMain
            indicator.startAnimating()

            let label = UILabel()
            label.text = "로딩중..."
            label.font = UIFont.customFont(ofSize: 16, weight: .medium)
            label.textColor = .customWh
            label.textAlignment = .center

            overlayView.addSubviews([indicator, label])
            indicator.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(40)
            }
            label.snp.makeConstraints { make in
                make.top.equalTo(indicator.snp.bottom).offset(8)
                make.centerX.equalToSuperview()
            }

            view.addSubview(overlayView)
            overlayView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.size.equalTo(CGSize(width: 140, height: 80))
            }

            UIView.animate(withDuration: 0.2) {
                overlayView.alpha = 1
            }

            self.loadingView = overlayView
            self.activityIndicator = indicator
        }
    }

    func hideLoading() {
        DispatchQueue.main.async {
            self.loadingView?.removeFromSuperview()
            self.activityIndicator.stopAnimating()
            self.loadingView = nil
            self.activityIndicator = nil
        }
    }
}
