
import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Data")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data stack load error: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    func fetchAccount() -> Account? {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.fetchLimit = 1
        return (try? context.fetch(request))?.first
    }

    private func saveUserInfo() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("CoreData save error: \(error)")
        }
    }

    func saveAccount(nickname: String) {
        let account = fetchAccount() ?? Account(context: context)
        account.nickname = nickname
        saveUserInfo()
    }

    func selectGenres(_ genres: [String]) {
        let account = fetchAccount() ?? Account(context: context)
        account.genres = genres as NSObject
        saveUserInfo()
    }

    func updateAgeRange(_ range: AgeRange) {
        let account = fetchAccount() ?? Account(context: context)
        account.age = range.rawValue
        saveUserInfo()
    }

    func updateGender(_ gender: Gender) {
        let account = fetchAccount() ?? Account(context: context)
        account.gender = gender.rawValue
        saveUserInfo()
    }
}
