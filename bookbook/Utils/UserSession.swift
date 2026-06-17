
import Foundation

enum UserSession {
    private static let uuidKey = "currentAccountUUID"
    private static let phoneKey = "currentPhoneNumber"
    private static let tutorialSeenKeyPrefix = "hasSeenTutorial_"

    static var currentAccountUUID: UUID? {
        get {
            guard let str = UserDefaults.standard.string(forKey: uuidKey) else { return nil }
            return UUID(uuidString: str)
        }
        set {
            if let uuid = newValue {
                UserDefaults.standard.set(uuid.uuidString, forKey: uuidKey)
            } else {
                UserDefaults.standard.removeObject(forKey: uuidKey)
            }
        }
    }
    
    static var currentPhoneNumber: String? {
        get {
            return UserDefaults.standard.string(forKey: phoneKey)
        }
        set {
            if let phone = newValue {
                UserDefaults.standard.set(phone, forKey: phoneKey)
            } else {
                UserDefaults.standard.removeObject(forKey: phoneKey)
            }
        }
    }

    static func clear() {
        UserDefaults.standard.removeObject(forKey: uuidKey)
        UserDefaults.standard.removeObject(forKey: phoneKey)
    }

    // MARK: - 튜토리얼 노출 여부

    /// 현재 계정이 튜토리얼을 이미 봤는지 여부.
    /// 계정 UUID 단위로 저장하므로, 탈퇴 후 재가입(새 UUID 발급) 시 자동으로 다시 노출된다.
    static var hasSeenTutorial: Bool {
        guard let uuid = currentAccountUUID else { return false }
        return UserDefaults.standard.bool(forKey: tutorialSeenKeyPrefix + uuid.uuidString)
    }

    /// 현재 계정이 튜토리얼을 봤다고 기록한다.
    static func markTutorialSeen() {
        guard let uuid = currentAccountUUID else { return }
        UserDefaults.standard.set(true, forKey: tutorialSeenKeyPrefix + uuid.uuidString)
    }
}
