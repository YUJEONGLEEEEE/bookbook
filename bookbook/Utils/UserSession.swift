
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
        if let uuid = currentAccountUUID {
            UserDefaults.standard.removeObject(forKey: tutorialSeenKeyPrefix + uuid.uuidString)
        }
        UserDefaults.standard.removeObject(forKey: uuidKey)
        UserDefaults.standard.removeObject(forKey: phoneKey)
    }

    static func scopedKey(_ base: String) -> String {
        "\(base)_\(currentAccountUUID?.uuidString ?? "guest")"
    }

    // MARK: - 튜토리얼 노출 여부

    static var hasSeenTutorial: Bool {
        guard let uuid = currentAccountUUID else { return false }
        return UserDefaults.standard.bool(forKey: tutorialSeenKeyPrefix + uuid.uuidString)
    }

    static func markTutorialSeen() {
        guard let uuid = currentAccountUUID else { return }
        UserDefaults.standard.set(true, forKey: tutorialSeenKeyPrefix + uuid.uuidString)
    }
}
