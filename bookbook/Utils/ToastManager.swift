
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
