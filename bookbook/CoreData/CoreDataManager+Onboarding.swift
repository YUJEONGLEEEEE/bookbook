
import Foundation
import CoreData

extension CoreDataManager {
    var isOnboardingCompleted: Bool {
        guard let account = fetchAccount() else { return false }

        let hasNickname = !(account.nickname?.isEmpty ?? true)
        let hasGenres = (account.genres as? [String])?.isEmpty == false
        let hasAge = account.age != 3
        let hasGender = !(account.gender?.isEmpty ?? true)

        return hasNickname && hasGenres && hasAge && hasGender
    }
}
