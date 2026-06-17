
import UIKit

/// 키보드 디스미스용 탭 제스처 전용 델리게이트.
/// 텍스트필드·버튼 같은 UIControl을 탭한 경우엔 제스처가 터치를 받지 않게 해서,
/// 입력 필드를 탭하면 키보드가 정상적으로 올라오고(즉시 닫히지 않고), 버튼 탭도 제 동작을 하도록 한다.
/// (UIGestureRecognizer.delegate 는 weak 참조라 싱글턴으로 안전하게 공유한다.)
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
