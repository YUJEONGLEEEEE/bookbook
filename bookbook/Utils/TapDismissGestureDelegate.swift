
import UIKit

final class TapDismissGestureDelegate: NSObject, UIGestureRecognizerDelegate {

    static let shared = TapDismissGestureDelegate()

    private override init() {}

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        var current = touch.view
        while let view = current {
            if view is UIControl { return false }
            current = view.superview
        }
        return true
    }
}
