
import Foundation
import CoreData

extension CoreDataManager {
    var isOnboardingCompleted: Bool {
        UserSession.hasSeenTutorial
    }
}
