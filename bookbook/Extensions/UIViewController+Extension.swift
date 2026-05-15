
import UIKit
import SnapKit

extension UIViewController {

    private func setupBackButton(imageName: String) {
        let image = UIImage(named: imageName)
        navigationController?.navigationBar.backIndicatorImage = image
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = image
        navigationItem.backButtonDisplayMode = .minimal
    }

    func setupWhiteBackButton() {
        setupBackButton(imageName: "icon_back_white")
    }

    func setupDefaultBackButton() {
        setupBackButton(imageName: "icon_back")
    }

    func setupKeyboardDismissMode() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(
            title: nil,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    func alertWithCancel(
        title: String? = nil,
        message: String,
        cancelTitle: String = "취소",
        confirmTitle: String = "확인",
        successMessage: String? = nil,
        okHandler: @escaping () -> Void) {
            let alert = UIAlertController(
                title: title,
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel))
            alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { [weak self] _ in
                okHandler()
                if let successMsg = successMessage, !successMsg.isEmpty {
                    self?.showAlert(message: successMsg)
                }
            })
            present(alert, animated: true)
        }

    func showToast(
        _ message: String,
        duration: TimeInterval = 2.0
    ) {
        ToastManager.shared.show(
            message: message,
            in: self,
            duration: duration
        )
    }

    func showToastInternal(
        message: String,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {

        let toastCard: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.bk1.withAlphaComponent(0.7)
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
            view.alpha = 0.0
            return view
        }()

        let text: UILabel = {
            let label = UILabel()
            label.text = message
            label.textColor = .customWh
            label.font = UIFont.customFont(ofSize: 17, weight: .medium)
            label.numberOfLines = 1
            return label
        }()

        toastCard.addSubview(text)
        text.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        view.addSubview(toastCard)
        toastCard.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(84)
        }

        UIView.animate(withDuration: 0.25) {
            toastCard.alpha = 1.0
        }

        UIView.animateKeyframes(
            withDuration: 0.3,
            delay: duration,
            options: []) {
                toastCard.alpha = 0.0
            } completion: { _ in
                toastCard.removeFromSuperview()
                completion()
            }
    }
}
