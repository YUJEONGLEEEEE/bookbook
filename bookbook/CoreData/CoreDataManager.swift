
import Foundation
import CoreData

// 좋아요/북마크 동기화용 알림
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
        // 모델 변경(속성 추가 등) 시 자동 경량 마이그레이션 — 기존 데이터 보존
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

    // 저장 성공 여부를 반환. 실패 시 변경을 롤백해 메모리 컨텍스트 일관성 유지.
    // viewContext는 메인 큐 컨텍스트이므로 반드시 메인 스레드에서 접근해야 한다(디버그에서 위반 시 즉시 감지).
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

    // 내 정보 저장 (닉네임 + 다짐 한마디)
    @discardableResult
    func updateProfile(nickname: String, promise: String) -> Bool {
        guard let account = fetchCurrentAccount() else { return false }
        account.nickname = nickname
        account.promise = promise
        return saveContext()
    }

    // 회원탈퇴: 모든 CoreData 데이터 삭제 (앱 최초 진입 상태로)
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

    // 현재 로그인된 계정과 그 활동 데이터(북마크/좋아요/책한줄)만 삭제 — 다른 계정은 보존
    // (관계 삭제규칙이 Nullify라 계정만 지우면 고아 데이터가 남으므로 직접 삭제)
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

    // 기기에 남아있는 계정 수
    func accountCount() -> Int {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        return (try? context.count(for: request)) ?? 0
    }

    func selectGenres(_ genres: [String]) {
        guard let account = fetchCurrentAccount() else { return }
        do {
            account.genres = try JSONEncoder().encode(genres) as NSObject
            saveContext()
            debugLog("genres 저장 성공: \(genres)")
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
            debugLog("genres 로드 성공: \(genres)")
            return genres
        } catch {
            debugLog("genres 로드 실패: \(error)")
            return []
        }
    }

    // 온보딩 미완료 이탈 시 선택값을 가입 직후 기본값(미선택)으로 되돌림
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
        // createdAt 최신순
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
        // isbn13은 Int64이므로 %lld로 비교 (%d는 큰 값이 잘려 매칭 실패)
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

        // isbn13은 Int64 → %lld
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
            liked.account = account   // 내가 좋아요 함
            saveContext()
            postBookStateChange(name: .bookLikeDidChange, isbn13: isbn13)
        } catch {
            debugLog("incrementLikeCount error: \(error)")
        }
    }

    // 좋아요/북마크 변경 알림
    func postBookStateChange(name: Notification.Name, isbn13: Int) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: [BookSyncKey.isbn13: isbn13])
    }

    func decrementLikeCount(for isbn13: Int) {
        // isbn13은 Int64 → %lld
        let request: NSFetchRequest<Liked> = Liked.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld", Int64(isbn13))

        do {
            if let liked = try context.fetch(request).first {
                liked.likedCount = max(Int64(0), liked.likedCount - 1)
                liked.account = nil   // 내 좋아요 해제
                // 좋아요 0 + book 없는 빈 레코드 정리
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

    // book을 함께 넘기면 북마크 추가 시 표시용 정보를 로컬에 캐시한다(내책장 빠른 로딩).
    // 북마크 해제 시에는 Bookmark→Book Cascade 규칙으로 캐시도 함께 삭제된다.
    func toggleBookmark(isbn13: Int, categoryId: Int64, book: BookData? = nil) {
        guard let account = fetchCurrentAccount() else { return }

        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld AND account == %@", Int64(isbn13), account)

        do {
            if let existing = try context.fetch(request).first {
                context.delete(existing)   // 연결된 Book 캐시도 Cascade로 삭제
                debugLog("북마크 취소: \(isbn13)")
            } else {
                let newBookmark = Bookmark(context: context)
                newBookmark.isbn13 = Int64(isbn13)
                newBookmark.categoryId = categoryId
                newBookmark.account = account
                newBookmark.createdAt = Date()
                if let book = book {
                    newBookmark.book = makeCachedBook(from: book)
                }
                debugLog("북마크 추가: \(isbn13), 카테고리: \(categoryId)")
            }
            saveContext()
            postBookStateChange(name: .bookBookmarkDidChange, isbn13: isbn13)
        } catch {
            debugLog("toggleBookmark error: \(error)")
        }
    }

    // BookData → Book(로컬 캐시) 엔티티 생성
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

    // Book(로컬 캐시) → BookData 복원 (내책장 표시용)
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

    // 검색 결과용: ISBN 리스트로 북마크 여부 일괄 확인
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

        // 최근 북마크 순으로 가져온다.
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

        // 표시 순서(최신순) 보존
        let order = bookmarks.map { String($0.isbn13) }

        // 캐시(Book) 적중분은 즉시, 누락분만 모아 네트워크로 보충
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

        // 모두 캐시 적중 → API 호출 없이 즉시 반환
        if missing.isEmpty {
            completion(order.compactMap { cached[$0] })
            return
        }

        // 캐시 없는(과거 북마크) 책만 알라딘에서 보충하고, 받은 김에 캐시도 채운다.
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

    // 과거(캐시 없이 생성된) 북마크에 표시 정보를 뒤늦게 채워 넣는다 → 다음 로딩부터 API 불필요.
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
