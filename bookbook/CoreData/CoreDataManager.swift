
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

    func saveAccount(nickname: String) {
        let account = fetchAccount() ?? Account(context: context)
        account.nickname = nickname
        try? context.save()
    }

    func selectGenres(_ genres: [String]) {
        let account = fetchAccount() ?? Account(context: context)
        account.genres = genres as NSObject
        do {
            try context.save()
        } catch {
            print("Failed to save genres: \(error)")
        }
    }
}
