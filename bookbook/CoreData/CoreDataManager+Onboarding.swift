
import Foundation
import CoreData

extension CoreDataManager {
    var isOnboardingCompleted: Bool {
        guard let account = fetchCurrentAccount() else { return false }

        let hasAge = account.age != 19
        let hasGender = !(account.gender?.isEmpty ?? true)

        return hasAge && hasGender
    }
}
