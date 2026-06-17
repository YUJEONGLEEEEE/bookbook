
import UIKit

// 앱의 메인 탭바
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

    // 윈도우 루트를 메인 탭바로 교체
    static func setAsRoot() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    // 이미 선택된 탭을 다시 누른 경우 처리
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if tabBarController.selectedViewController === viewController,
           let nav = viewController as? UINavigationController {
            // 찾기 탭 재탭 → 루트로 이동 + 검색 초기 화면으로 리셋
            // 찾기 탭 재탭 → 루트로 이동 + 검색 초기 화면으로 리셋
            if let searchVC = nav.viewControllers.first as? SearchViewController {
                nav.popToRootViewController(animated: false)
                searchVC.resetToInitialScreen()
            }
        }
        return true
    }
}
