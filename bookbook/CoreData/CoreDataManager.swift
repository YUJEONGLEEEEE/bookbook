
import Foundation
import CoreData

extension Notification.Name {
    static let bookLikeDidChange = Notification.Name("bookLikeDidChange")
    static let bookBookmarkDidChange = Notification.Name("bookBookmarkDidChange")
}

enum BookSyncKey {
    static let isbn13 = "isbn13"
}

final class CoreDataManager {
    static let shared = CoreDataManager()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Data")
        if let description = container.persistentStoreDescriptions.first {
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data stack load error: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    private init() {}

    // MARK: - Account Fetch

    func fetchAccount(by uuid: UUID) -> Account? {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
        return (try? context.fetch(request))?.first
    }

    func fetchAccount(by phoneNumber: String) -> Account? {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "phoneNumber == %@", phoneNumber)
        return (try? context.fetch(request))?.first
    }

    func fetchCurrentAccount() -> Account? {
        guard let uuid = UserSession.currentAccountUUID else { return nil }
        return fetchAccount(by: uuid)
    }

    // MARK: - Save

    @discardableResult
    private func saveContext() -> Bool {
        assert(Thread.isMainThread, "CoreData(viewContext) 저장은 메인 스레드에서만 호출해야 함")
        guard context.hasChanges else { return true }
        do {
            try context.save()
            return true
        } catch {
            debugLog("CoreData save error: \(error)")
            context.rollback()
            return false
        }
    }

    // MARK: - Account 생성/수정

    func saveAccount(uuid: UUID, nickname: String, phoneNumber: String) {
        let account = fetchAccount(by: uuid) ?? Account(context: context)
        account.id = uuid
        account.nickname = nickname
        account.phoneNumber = phoneNumber
        if account.genres == nil {
            account.genres = Data() as NSObject
        }
        account.age = 19
        account.gender = ""
        saveContext()
    }

    @discardableResult
    func updateProfile(nickname: String, promise: String) -> Bool {
        guard let account = fetchCurrentAccount() else { return false }
        account.nickname = nickname
        account.promise = promise
        return saveContext()
    }

    func deleteAllData() {
        let names = ["Account", "Bookmark", "Liked", "Comment", "Book"]
        for name in names {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            let delete = NSBatchDeleteRequest(fetchRequest: fetch)
            do { try context.execute(delete) }
            catch { debugLog("deleteAllData(\(name)) error: \(error)") }
        }
        context.reset()
    }

    func deleteCurrentAccount() {
        guard let account = fetchCurrentAccount() else { return }
        for name in ["Bookmark", "Liked", "Comment"] {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            fetch.predicate = NSPredicate(format: "account == %@", account)
            if let rows = (try? context.fetch(fetch)) as? [NSManagedObject] {
                rows.forEach { context.delete($0) }
            }
        }
        context.delete(account)
        saveContext()
    }

    func accountCount() -> Int {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        return (try? context.count(for: request)) ?? 0
    }

    func selectGenres(_ genres: [String]) {
        guard let account = fetchCurrentAccount() else { return }
        do {
            account.genres = try JSONEncoder().encode(genres) as NSObject
            saveContext()
        } catch {
            debugLog("genres 저장 실패: \(error)")
        }
    }

    func updateAgeRange(_ range: AgeRange) {
        guard let account = fetchCurrentAccount() else { return }
        account.age = Int16(range.rawValue)
        saveContext()
    }

    func updateGender(_ gender: Gender) {
        guard let account = fetchCurrentAccount() else { return }
        account.gender = gender.rawValue
        saveContext()
    }

    func fetchAgeRange() -> AgeRange? {
        guard let account = fetchCurrentAccount() else { return nil }
        return AgeRange(rawValue: account.age)
    }

    func fetchGender() -> Gender? {
        guard let account = fetchCurrentAccount(),
              let gender = account.gender else { return nil }
        return Gender(rawValue: gender)
    }

    func fetchGenres() -> [String] {
        guard let account = fetchCurrentAccount(),
              let genreData = account.genres as? Data, !genreData.isEmpty else {
            return []
        }
        do {
            let genres = try JSONDecoder().decode([String].self, from: genreData)
            return genres
        } catch {
            debugLog("genres 로드 실패: \(error)")
            return []
        }
    }

    func resetOnboardingSelections() {
        guard let account = fetchCurrentAccount() else { return }
        account.age = 19
        account.gender = ""
        account.genres = Data() as NSObject
        saveContext()
    }
}

// MARK: - Liked

extension CoreDataManager {

    func fetchLikedBooks(completion: @escaping ([BookData]) -> Void) {
        guard let account = fetchCurrentAccount() else {
            completion([])
            return
        }

        let request: NSFetchRequest<Liked> = Liked.fetchRequest()
        request.predicate = NSPredicate(format: "account == %@", account)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Liked.createdAt, ascending: false)
        ]

        do {
            let likedList = try context.fetch(request)
            let isbns = likedList.compactMap { String($0.isbn13) }

            guard !isbns.isEmpty else {
                completion([])
                return
            }

            NetworkManager.shared.fetchBookmarkedBooks(isbns: isbns) { books in
                var mappedBooks = books

                for i in 0..<mappedBooks.count {
                    let isbnStr = mappedBooks[i].isbn13
                    if let liked = likedList.first(where: { String($0.isbn13) == isbnStr }) {
                        mappedBooks[i].likedCount = Int(liked.likedCount)
                    }
                }
                completion(mappedBooks)
            }
        } catch {
            debugLog("fetchLikedBooks error: \(error)")
            completion([])
        }
    }

    func applyLikedCount(to books: inout [BookData]) {
        let request: NSFetchRequest<Liked> = Liked.fetchRequest()

        guard let likedList = try? context.fetch(request) else { return }

        let likedDict: [String: Int] = likedList.reduce(into: [:]) { dict, liked in
            dict[String(liked.isbn13)] = Int(liked.likedCount)
        }

        for index in books.indices {
            books[index].likedCount = likedDict[books[index].isbn13] ?? 0
        }
    }

    func getLikedCount(for isbn13: Int) -> Int {
        let request: NSFetchRequest<Liked> = Liked.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld", Int64(isbn13))

        return Int((try? context.fetch(request).first)?.likedCount ?? 0)
    }

    func isLikedByUser(isbn13: Int) -> Bool {
        guard let account = fetchCurrentAccount() else { return false }

        let request: NSFetchRequest<Liked> = Liked.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld AND account == %@", Int64(isbn13), account)

        do {
            return try context.count(for: request) > 0
        } catch {
            debugLog("isLikedByUser fetch error: \(error)")
            return false
        }
    }

    func incrementLikeCount(for isbn13: Int) {
        guard let account = fetchCurrentAccount() else { return }

        let request: NSFetchRequest<Liked> = Liked.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld", Int64(isbn13))

        do {
            let liked: Liked
            if let existing = try context.fetch(request).first {
                liked = existing
            } else {
                liked = Liked(context: context)
                liked.isbn13 = Int64(isbn13)
                liked.likedCount = 0
                liked.createdAt = Date()
            }
            liked.likedCount += 1
            liked.account = account
            saveContext()
            postBookStateChange(name: .bookLikeDidChange, isbn13: isbn13)
        } catch {
            debugLog("incrementLikeCount error: \(error)")
        }
    }

    func postBookStateChange(name: Notification.Name, isbn13: Int) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: [BookSyncKey.isbn13: isbn13])
    }

    func decrementLikeCount(for isbn13: Int) {
        let request: NSFetchRequest<Liked> = Liked.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld", Int64(isbn13))

        do {
            if let liked = try context.fetch(request).first {
                liked.likedCount = max(Int64(0), liked.likedCount - 1)
                liked.account = nil
                if liked.likedCount == 0 && liked.book == nil {
                    context.delete(liked)
                }
                saveContext()
                postBookStateChange(name: .bookLikeDidChange, isbn13: isbn13)
            }
        } catch {
            debugLog("decrementLikeCount error: \(error)")
        }
    }
}

// MARK: - Bookmark

extension CoreDataManager {
    func isBookmarked(isbn13: Int) -> Bool {
        guard let account = fetchCurrentAccount() else { return false }

        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld AND account == %@", Int64(isbn13), account)

        do {
            return try context.count(for: request) > 0
        } catch {
            debugLog("isBookmarked error: \(error)")
            return false
        }
    }

    func toggleBookmark(isbn13: Int, categoryId: Int64, book: BookData? = nil) {
        guard let account = fetchCurrentAccount() else { return }

        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld AND account == %@", Int64(isbn13), account)

        do {
            if let existing = try context.fetch(request).first {
                context.delete(existing)
            } else {
                let newBookmark = Bookmark(context: context)
                newBookmark.isbn13 = Int64(isbn13)
                newBookmark.categoryId = categoryId
                newBookmark.account = account
                newBookmark.createdAt = Date()
                if let book = book {
                    newBookmark.book = makeCachedBook(from: book)
                }
            }
            saveContext()
            postBookStateChange(name: .bookBookmarkDidChange, isbn13: isbn13)
        } catch {
            debugLog("toggleBookmark error: \(error)")
        }
    }

    private func makeCachedBook(from book: BookData) -> Book {
        let cached = Book(context: context)
        cached.isbn13 = book.isbn13
        cached.title = book.title
        cached.author = book.author
        cached.image = book.cover
        cached.publisher = book.publisher
        cached.story = book.description
        cached.categoryName = book.categoryName
        cached.searchCategoryId = book.categoryId
        return cached
    }

    private func bookData(from cached: Book) -> BookData {
        var data = BookData(
            title: cached.title ?? "",
            author: cached.author ?? "",
            pubDate: "",
            description: cached.story ?? "",
            isbn13: cached.isbn13 ?? "",
            cover: cached.image ?? "",
            publisher: cached.publisher ?? ""
        )
        data.categoryName = cached.categoryName ?? ""
        data.categoryId = cached.searchCategoryId
        data.isBookmarked = true
        return data
    }

    func applyBookmarkStatus(to books: inout [BookData]) {
        guard let account = fetchCurrentAccount() else { return }

        let isbns = books.compactMap { Int64($0.isbn13) }
        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "account == %@ AND isbn13 IN %@", account, isbns)

        do {
            let bookmarks = try context.fetch(request)
            let bookmarkedIsbns = Set(bookmarks.map { $0.isbn13 })

            for i in 0..<books.count {
                if let isbnInt64 = Int64(books[i].isbn13) {
                    books[i].isBookmarked = bookmarkedIsbns.contains(isbnInt64)
                }
            }
        } catch {
            debugLog("applyBookmarkStatus error: \(error)")
        }
    }

    func fetchBookmarkedBooks(completion: @escaping ([BookData]) -> Void) {
        guard let account = fetchCurrentAccount() else {
            completion([])
            return
        }

        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "account == %@", account)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Bookmark.createdAt, ascending: false)
        ]

        let bookmarks: [Bookmark]
        do {
            bookmarks = try context.fetch(request)
        } catch {
            debugLog("fetchBookmarkedBooks error: \(error)")
            completion([])
            return
        }

        let order = bookmarks.map { String($0.isbn13) }

        var cached: [String: BookData] = [:]
        var missing: [String] = []
        for bookmark in bookmarks {
            let isbn = String(bookmark.isbn13)
            if let book = bookmark.book {
                cached[isbn] = bookData(from: book)
            } else {
                missing.append(isbn)
            }
        }

        if missing.isEmpty {
            completion(order.compactMap { cached[$0] })
            return
        }

        NetworkManager.shared.fetchBookmarkedBooks(isbns: missing) { [weak self] fetched in
            guard let self = self else { completion([]); return }
            for var book in fetched {
                book.isBookmarked = true
                cached[book.isbn13] = book
                self.backfillCache(isbn13: book.isbn13, with: book, account: account)
            }
            self.saveContext()
            completion(order.compactMap { cached[$0] })
        }
    }

    private func backfillCache(isbn13: String, with book: BookData, account: Account) {
        guard let isbnInt = Int64(isbn13) else { return }
        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld AND account == %@", isbnInt, account)
        guard let bookmark = (try? context.fetch(request))?.first, bookmark.book == nil else { return }
        bookmark.book = makeCachedBook(from: book)
    }

    func fetchBookmarkedBooksWithCategory() -> [String: Int64] {
        guard let account = fetchCurrentAccount() else { return [:] }

        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "account == %@", account)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Bookmark.createdAt, ascending: false)
        ]

        do {
            let bookmarks = try context.fetch(request)
            return bookmarks.reduce(into: [:]) { dict, bookmark in
                dict[String(bookmark.isbn13)] = bookmark.categoryId
            }
        } catch {
            debugLog("fetchBookmarkedBooksWithCategory error: \(error)")
            return [:]
        }
    }

    func getBookmarkCategoryId(isbn13: Int) -> Int64 {
        guard let account = fetchCurrentAccount() else { return 0 }

        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld AND account == %@", Int64(isbn13), account)

        do {
            let bookmark = try context.fetch(request).first
            return bookmark?.categoryId ?? 0
        } catch {
            debugLog("getBookmarkCategoryId error: \(error)")
            return 0
        }
    }

    func fetchBookmarkedISBNs() -> [String] {
        guard let account = fetchCurrentAccount() else { return [] }

        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "account == %@", account)

        do {
            let bookmarks = try context.fetch(request)
            return bookmarks.compactMap { String($0.isbn13) }
        } catch {
            debugLog("fetchBookmarkedISBNs error: \(error)")
            return []
        }
    }

    func deleteBookmark(isbn13: Int) {
        guard let account = fetchCurrentAccount() else { return }

        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld AND account == %@", Int64(isbn13), account)

        do {
            let bookmarks = try context.fetch(request)
            bookmarks.forEach { context.delete($0) }
            saveContext()
            postBookStateChange(name: .bookBookmarkDidChange, isbn13: isbn13)
        } catch {
            debugLog("deleteBookmark error: \(error)")
        }
    }
}

// MARK: - Comment

extension CoreDataManager {

    @discardableResult
    func saveComment(isbn13: Int64, readDate: Date, rating: Double, comment: String) -> Bool {
        guard let account = fetchCurrentAccount() else { return false }
        let entity = Comment(context: context)
        entity.account = account
        entity.isbn13 = isbn13
        entity.readDate = readDate
        entity.rating = rating
        entity.comment = comment
        entity.createdAt = Date()
        return saveContext()
    }

    @discardableResult
    func updateComment(_ comment: Comment, readDate: Date, rating: Double, text: String) -> Bool {
        comment.readDate = readDate
        comment.rating = rating
        comment.comment = text
        return saveContext()
    }

    func fetchComments(completion: @escaping ([Comment]) -> Void) {
        guard let account = fetchCurrentAccount() else {
            completion([])
            return
        }

        let request: NSFetchRequest<Comment> = Comment.fetchRequest()
        request.predicate = NSPredicate(format: "account == %@", account)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Comment.readDate, ascending: false)]

        context.perform {
            do {
                let comments = try self.context.fetch(request)
                DispatchQueue.main.async {
                    completion(comments)
                }
            } catch {
                debugLog("fetchComments error: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    func deleteComment(_ comment: Comment) {
        context.delete(comment)
        saveContext()
    }

    func hasComment(for isbn13: Int64) -> Bool {
        guard let account = fetchCurrentAccount() else { return false }

        let request: NSFetchRequest<Comment> = Comment.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld AND account == %@", isbn13, account)
        request.fetchLimit = 1

        do {
            return try context.count(for: request) > 0
        } catch {
            debugLog("hasComment error: \(error)")
            return false
        }
    }
}
