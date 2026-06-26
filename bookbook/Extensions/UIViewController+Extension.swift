
import UIKit
import SnapKit

extension UIViewController {

    private func setupBackButton(imageName: String) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.isTranslucent = true

        let backItem = UIBarButtonItem(
            image: UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(handleBackButton)
        )
        // iOS 26: 바 버튼 Liquid Glass 배경 제거
        if #available(iOS 26.0, *) {
            backItem.hidesSharedBackground = true
        }
        navigationItem.leftBarButtonItem = backItem
        navigationController?.navigationBar.backIndicatorImage = UIImage()
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage()
        navigationItem.backButtonDisplayMode = .minimal
    }
    @objc private func handleBackButton() {
        navigationController?.popViewController(animated: true)
    }

    func setupWhiteBackButton() {
        setupBackButton(imageName: "chevron.backward_white")
    }

    func setupDefaultBackButton() {
        setupBackButton(imageName: "backchevron")
    }

    func setupKeyboardDismissMode() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tap.delegate = TapDismissGestureDelegate.shared
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(self, selector: #selector(keybordWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc private func keybordWillShow(_ notification: Notification) {
        hideOrShowToolbar(in: view, hidden: false)
        adjustViewForKeyboard(notification: notification)
    }
    @objc private func keyboardWillHide(_ notification: Notification) {
        hideOrShowToolbar(in: view, hidden: true)
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        UIView.animate(withDuration: duration) {
            self.view.transform = .identity
        }
    }

    private func adjustViewForKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let kbFrameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let responder = currentFirstResponderView(in: view) else { return }

        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.25
        let currentTy = view.transform.ty
        let responderBottomInWindow = responder.convert(responder.bounds, to: nil).maxY - currentTy
        let keyboardTopInWindow = kbFrameEnd.minY
        let padding: CGFloat = 16
        let offset = max(0, responderBottomInWindow + padding - keyboardTopInWindow)

        UIView.animate(withDuration: duration) {
            self.view.transform = offset > 0 ? CGAffineTransform(translationX: 0, y: -offset) : .identity
        }
    }

    private func currentFirstResponderView(in view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        for sub in view.subviews {
            if let found = currentFirstResponderView(in: sub) { return found }
        }
        return nil
    }

    private func hideOrShowToolbar(in view: UIView, hidden: Bool) {
        for subview in view.subviews {
            if let textField = subview as? UITextField,
               let toolbar = textField.inputAccessoryView as? UIToolbar {
                toolbar.isHidden = hidden
            }
            hideOrShowToolbar(in: subview, hidden: hidden)
        }
    }

    func presentCustomAlert(title: String? = nil, message: String, actions: [CustomAlertAction], input: CustomAlertTextInput? = nil) {
        let alert = CustomAlertViewController(title: title, message: message, actions: actions, input: input)
        present(alert, animated: true)
    }

    func showAlert(message: String) {
        presentCustomAlert(message: message, actions: [CustomAlertAction(title: "확인")])
    }

    func showErrorAlert() {
        guard presentedViewController == nil else { return }
        showAlert(message: "오류가 발생했어요.\n잠시 후 다시 시도해주세요.")
    }

    func showAlert(message: String, onConfirm: @escaping () -> Void) {
        presentCustomAlert(message: message, actions: [CustomAlertAction(title: "확인", handler: onConfirm)])
    }

    func alertWithCancel(
        title: String? = nil,
        message: String,
        cancelTitle: String = "취소",
        confirmTitle: String = "확인",
        successMessage: String? = nil,
        okHandler: @escaping () -> Void) {
            presentCustomAlert(title: title, message: message, actions: [
                CustomAlertAction(title: cancelTitle, titleColor: .bk2, handler: nil),
                CustomAlertAction(title: confirmTitle, titleColor: .customBtn, handler: { [weak self] in
                    okHandler()
                    if let successMsg = successMessage, !successMsg.isEmpty {
                        self?.showAlert(message: successMsg)
                    }
                })
            ])
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

    func showPendingToast() {
        ToastManager.shared.showPending(in: self)
    }

    func showToastInternal(
        message: String,
        duration: TimeInterval,
        completion: @escaping () -> Void
    ) {

        let toastCard: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
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
            label.textAlignment = .center
            label.numberOfLines = 0
            return label
        }()

        toastCard.addSubview(text)
        text.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(20)
            make.horizontalEdges.equalToSuperview().inset(24)
        }

        view.addSubview(toastCard)
        toastCard.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(74) // Figma(1007:3831): 화면 바닥에서 108pt
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().inset(24)
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
