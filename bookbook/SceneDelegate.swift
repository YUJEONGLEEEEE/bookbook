
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)

        window?.rootViewController = makeRootViewController()
        window?.backgroundColor = .black   // 화면전환 시 둥근 모서리에 흰 배경 비치는 것 방지
        window?.makeKeyAndVisible()
    }

    private func makeRootViewController() -> UIViewController {
        // 세션 + 온보딩 완료 → 메인. 그 외(로그아웃/온보딩 미완료/최초/탈퇴) → SignUp 진입.
        // (온보딩 미완료 계정은 SignUp에서 로그인으로 이동 → 로그인 시 취향 선택으로 이어짐)
        if UserSession.currentAccountUUID != nil,
           CoreDataManager.shared.isOnboardingCompleted {
            return MainTabBarController()
        }
        return AuthNavigationController(rootViewController: SignUpViewController())
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
