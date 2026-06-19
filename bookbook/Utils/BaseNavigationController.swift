
import UIKit

// 앱 전역 네비게이션 컨트롤러 (백버튼 커스텀 chevron 자동 교체)
class BaseNavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        // 네비게이션 바 투명 처리
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.shadowColor = .clear
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.isTranslucent = true

        // 커스텀 백버튼 사용 시 스와이프-백 제스처 복원
        interactivePopGestureRecognizer?.delegate = self
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        guard viewController != viewControllers.first,
              viewController.navigationItem.leftBarButtonItem == nil,
              !viewController.navigationItem.hidesBackButton else { return }
        viewController.setupDefaultBackButton()
    }

    // 스와이프-백: 뒤로 갈 화면이 있을 때만 허용
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
