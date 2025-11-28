
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)

        let rootVC: UIViewController

        if CoreDataManager.shared.isOnboardingCompleted {
            rootVC = makeTabBarController()
        } else {
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            rootVC = nav
        }

        window?.rootViewController = rootVC
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()
    }

    private func makeTabBarController() -> UITabBarController {
        let homeImage = UIImage(named: "icon_home")?.withRenderingMode(.alwaysTemplate)
        let searchImage = UIImage(named: "icon_search")?.withRenderingMode(.alwaysTemplate)
        let bookmarkImage = UIImage(named: "icon_shelf")?.withRenderingMode(.alwaysTemplate)
        let commentImage = UIImage(named: "icon_line")?.withRenderingMode(.alwaysTemplate)
        let myImage = UIImage(named: "icon_my")?.withRenderingMode(.alwaysTemplate)

        let mainVC = MainViewController()
        mainVC.tabBarItem = UITabBarItem(title: "홈", image: homeImage, tag: 0)
        let mainNav = UINavigationController(rootViewController: mainVC)

        let searchVC = SearchViewController()
        searchVC.tabBarItem = UITabBarItem(title: "찾기", image: searchImage, tag: 1)
        let searchNav = UINavigationController(rootViewController: searchVC)

        let bookmarkVC = BookmarkViewController()
        bookmarkVC.tabBarItem = UITabBarItem(title: "내책장", image: bookmarkImage, tag: 2)
        let bookmarkNav = UINavigationController(rootViewController: bookmarkVC)

        let myCommentsVC = MyCommentsViewController()
        myCommentsVC.tabBarItem = UITabBarItem(title: "책한줄", image: commentImage, tag: 3)
        let myCommentsNav = UINavigationController(rootViewController: myCommentsVC)

        let myPageVC = MyPageViewController()
        myPageVC.tabBarItem = UITabBarItem(title: "내공간", image: myImage, tag: 4)
        let myPageNav = UINavigationController(rootViewController: myPageVC)

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [mainNav, searchNav, bookmarkNav, myCommentsNav, myPageNav]
        tabBarController.tabBar.tintColor = .customMain
        tabBarController.tabBar.unselectedItemTintColor = .bk3

        UINavigationBar.appearance().tintColor = .black
        return tabBarController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}

