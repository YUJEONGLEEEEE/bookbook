
import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        configureTabs()
        configureAppearance()
    }

    private func configureTabs() {
        viewControllers = [
            makeTab(MainViewController(),       title: "홈",     off: "home_off",      on: "home_on",      tag: 0),
            makeTab(SearchViewController(),     title: "찾기",   off: "search_off",    on: "search_on",    tag: 1),
            makeTab(BookmarkViewController(),   title: "내책장", off: "bookshelf_off", on: "bookshelf_on", tag: 2),
            makeTab(MyCommentsViewController(), title: "책한줄", off: "comments_off",  on: "comments_on",  tag: 3),
            makeTab(MyPageViewController(),     title: "내공간", off: "mypage_off",    on: "mypage_on",    tag: 4),
        ]
    }

    private func makeTab(
        _ root: UIViewController,
        title: String,
        off: String,
        on: String,
        tag: Int
    ) -> UINavigationController {
        // 탭바 아이콘은 에셋 원본 색 사용
        root.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: off)?.withRenderingMode(.alwaysOriginal),
            selectedImage: UIImage(named: on)?.withRenderingMode(.alwaysOriginal)
        )
        root.tabBarItem.tag = tag
        return BaseNavigationController(rootViewController: root)
    }

    private func configureAppearance() {
        tabBar.tintColor = .customMain
        tabBar.unselectedItemTintColor = .bk3
    }

    static func setAsRoot() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()
    }
}

// 이미 선택된 탭을 다시 누르면 호출 — 각 탭 루트 VC가 콘텐츠를 초기화/새로고침
protocol TabReselectable: AnyObject {
    func handleTabReselect()
}

extension MainTabBarController: UITabBarControllerDelegate {
    // 이미 선택된 탭을 다시 누른 경우만 처리 (다른 탭에서 이동해 온 경우는 이전 상태 유지)
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard tabBarController.selectedViewController === viewController,
              let nav = viewController as? UINavigationController else {
            return true
        }
        // 푸시된 상세 화면이 있으면 먼저 루트로 이동
        if nav.viewControllers.count > 1 {
            nav.popToRootViewController(animated: true)
        }
        if let reselectable = nav.viewControllers.first as? TabReselectable {
            reselectable.handleTabReselect()
        }
        return true
    }
}
