
import UIKit

final class ToastManager {
    static let shared = ToastManager()

    private var queue: [ToastRequest] = []
    private var isShowing = false

    // 화면 전환(가입/로그인) 직후, 도착 화면에서 한 번 띄울 대기 메시지
    var pendingMessage: String?

    private init() {}

    // 대기 메시지가 있으면 해당 화면에서 표시하고 비운다.
    func showPending(in viewController: UIViewController) {
        guard let message = pendingMessage else { return }
        pendingMessage = nil
        show(message: message, in: viewController)
    }

    struct ToastRequest {
        let viewController: UIViewController
        let message: String
        let duration: TimeInterval
    }

    func show(
        message: String,
        in viewController: UIViewController,
        duration: TimeInterval = 2.0
    ) {
        let request = ToastRequest(
            viewController: viewController,
            message: message,
            duration: duration
        )
        queue.append(request)
        comingUpNext()
    }

    private func comingUpNext() {
        guard !isShowing, queue.isEmpty == false else { return }
        isShowing = true
        let request = queue.removeFirst()

        DispatchQueue.main.async {
            request.viewController.showToastInternal(
                message: request.message,
                duration: request.duration) {
                    [weak self] in
                    self?.isShowing = false
                    self?.comingUpNext()
                }
        }
    }
}
