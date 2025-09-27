//
//  SceneDelegate.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)

        let mainVC = MainViewController()
        mainVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        let mainNav = UINavigationController(rootViewController: mainVC)

        let searchVC = SearchViewController()
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        let searchNav = UINavigationController(rootViewController: searchVC)

        let bookmarkVC = BookmarkViewController()
        bookmarkVC.tabBarItem = UITabBarItem(title: "Bookmark", image: UIImage(systemName: "bookmark"), tag: 2)
        let bookmarkNav = UINavigationController(rootViewController: bookmarkVC)

        let myCommentsVC = MyCommentsViewController()
        myCommentsVC.tabBarItem = UITabBarItem(title: "MyComments", image: UIImage(systemName: "ellipsis.bubble.fill"), tag: 3)
        let myCommentsNav = UINavigationController(rootViewController: myCommentsVC)

        let myPageVC = MyPageViewController()
        myPageVC.tabBarItem = UITabBarItem(title: "MyPage", image: UIImage(systemName: "person.circle"), tag: 4)
        let myPageNav = UINavigationController(rootViewController: myPageVC)

        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = .black
        tabBarController.viewControllers = [mainNav, searchNav, bookmarkNav, myCommentsNav, myPageNav]

        UINavigationBar.appearance().tintColor = .black

        window?.rootViewController = tabBarController
        window?.backgroundColor = .white
        window?.makeKeyAndVisible()

        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

