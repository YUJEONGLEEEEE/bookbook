import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationManager.requestAuthorization()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    // 앱이 포그라운드일 때도 배너를 표시
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .list])
    }

    // 푸시(잠금화면/배너) 탭 시 종류에 따라 화면 이동
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if userInfo["kind"] as? String == AppNotificationKind.bookReward.rawValue {
            // 콜드 스타트 시 씬/루트가 준비될 시간을 약간 주고 이동
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                AppDelegate.routeToBookTower()
            }
        }
        completionHandler()
    }

    // 현재 탭의 네비게이션에 책탑쌓기 페이지를 push (로그인 후 메인 탭일 때만)
    private static func routeToBookTower() {
        guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene }).first,
              let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first,
              let tab = window.rootViewController as? MainTabBarController,
              let nav = tab.selectedViewController as? UINavigationController else { return }
        // 이미 책탑쌓기 화면이면 중복 push 방지
        guard !(nav.topViewController is LevelEventViewController) else { return }
        nav.pushViewController(LevelEventViewController(), animated: true)
    }
}
