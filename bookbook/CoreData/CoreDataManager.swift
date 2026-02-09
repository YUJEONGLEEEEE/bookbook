
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
            print("coredata 저장 성공")
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
        do {
            let genreData = try JSONEncoder().encode(genres)
            account.genres = genreData as NSObject
            saveUserInfo()
            print("genres 저장 성공: \(genres)")
        } catch {
            print("genres 저장 실패: \(error)")
        }
    }

    func updateAgeRange(_ range: AgeRange) {
        let account = fetchAccount() ?? Account(context: context)
        account.age = Int16(range.rawValue)
        saveUserInfo()
    }

    func updateGender(_ gender: Gender) {
        let account = fetchAccount() ?? Account(context: context)
        account.gender = gender.rawValue
        saveUserInfo()
    }

    func fetchGenres() -> [String] {
        guard let account = fetchAccount(),
              let genreData = account.genres as? Data else {
            return []
        }
        do {
            let genres = try JSONDecoder().decode([String].self, from: genreData)
            print("genres 로드 성공: \(genres)")
            return genres
        } catch {
            print("genres 로드 실패: \(error)")
            return []
        }
    }
}
