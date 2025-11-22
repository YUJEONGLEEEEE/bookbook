
import UIKit

final class ToastManager {
    static let shared = ToastManager()

    private var queue: [ToastRequest] = []
    private var isShowing = false

    private init() {}

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
            viewController: inViewController,
            message: message,
            duration: duration
        )
        queue.append(request)
    }

    private func comingUpNext() {
        guard !isShowing, queue.isEmpty == false else { return }
        isShowing = true
        let request = queue.removeFirst()
        request.viewController.showToastInternal(
            message: request.message,
            duration: request.duration
        ) { [weak self] in
            self?.isShowing = false
            self?.comingUpNext()
        }
    }
}
