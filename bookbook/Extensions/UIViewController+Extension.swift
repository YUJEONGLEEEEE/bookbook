
import UIKit
import SnapKit

extension UIViewController {

    func setupKeyboardDismissMode() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    func alertWithCancel(title: String, message: String, okHandler: @escaping () -> Void) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            okHandler()
        }))
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
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
        label.snp.makeConstraints { make in
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
            options: .curveEaseOut) {
                toastCard.alpha = 0.0
            } completion: { _ in
                toastCard.removeFromSuperview()
                completion()
            }
    }
}
