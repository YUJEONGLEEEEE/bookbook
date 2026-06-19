
import Foundation
import CoreData

extension CoreDataManager {
    // 온보딩 완료 = 튜토리얼까지 끝낸 상태(마지막 단계에서만 기록).
    // 나이·성별은 선택 즉시 저장되므로 완료 판정 기준으로 쓰면 안 됨(미완료에도 true가 됨).
    var isOnboardingCompleted: Bool {
        UserSession.hasSeenTutorial
    }
}
