
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

protocol TabReselectable: AnyObject {
    func handleTabReselect()
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard tabBarController.selectedViewController === viewController,
              let nav = viewController as? UINavigationController else {
            return true
        }
        if nav.viewControllers.count > 1 {
            nav.popToRootViewController(animated: true)
        }
        if let reselectable = nav.viewControllers.first as? TabReselectable {
            reselectable.handleTabReselect()
        }
        return true
    }
}
