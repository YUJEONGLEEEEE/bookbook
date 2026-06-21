
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
        // uuid 제거 전에 현재 계정의 튜토리얼 플래그(계정별 키)도 정리 — 고아 키 방지
        if let uuid = currentAccountUUID {
            UserDefaults.standard.removeObject(forKey: tutorialSeenKeyPrefix + uuid.uuidString)
        }
        UserDefaults.standard.removeObject(forKey: uuidKey)
        UserDefaults.standard.removeObject(forKey: phoneKey)
    }

    /// 현재 계정 UUID로 네임스페이스한 UserDefaults 키 (계정별 데이터 분리용).
    /// 계정 미설정 시 "guest" 슬롯 사용.
    static func scopedKey(_ base: String) -> String {
        "\(base)_\(currentAccountUUID?.uuidString ?? "guest")"
    }

    // MARK: - 튜토리얼 노출 여부

    /// 현재 계정이 튜토리얼을 이미 봤는지 여부.
    /// 계정 UUID 단위로 저장하므로, 탈퇴 후 재가입(새 UUID 발급) 시 자동으로 다시 노출된다.
    static var hasSeenTutorial: Bool {
        guard let uuid = currentAccountUUID else { return false }
        return UserDefaults.standard.bool(forKey: tutorialSeenKeyPrefix + uuid.uuidString)
    }

    static func markTutorialSeen() {
        guard let uuid = currentAccountUUID else { return }
        UserDefaults.standard.set(true, forKey: tutorialSeenKeyPrefix + uuid.uuidString)
    }
}
