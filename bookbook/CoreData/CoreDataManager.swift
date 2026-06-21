
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

    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
            debugLog("coredata 저장 성공")
        } catch {
            debugLog("CoreData save error: \(error)")
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
    func updateProfile(nickname: String, promise: String) {
        guard let account = fetchCurrentAccount() else { return }
        account.nickname = nickname
        account.promise = promise
        saveContext()
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

    func toggleBookmark(isbn13: Int, categoryId: Int64) {
        guard let account = fetchCurrentAccount() else { return }

        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "isbn13 == %lld AND account == %@", Int64(isbn13), account)

        do {
            if let existing = try context.fetch(request).first {
                context.delete(existing)
                debugLog("북마크 취소: \(isbn13)")
            } else {
                let newBookmark = Bookmark(context: context)
                newBookmark.isbn13 = Int64(isbn13)
                newBookmark.categoryId = categoryId
                newBookmark.account = account
                newBookmark.createdAt = Date()
                debugLog("북마크 추가: \(isbn13), 카테고리: \(categoryId)")
            }
            saveContext()
            postBookStateChange(name: .bookBookmarkDidChange, isbn13: isbn13)
        } catch {
            debugLog("toggleBookmark error: \(error)")
        }
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

        // 최근 북마크 순으로 ISBN 목록을 가져온다.
        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "account == %@", account)
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Bookmark.createdAt, ascending: false)
        ]

        let bookmarkedISBNs: [String]
        do {
            bookmarkedISBNs = try context.fetch(request).map { String($0.isbn13) }
        } catch {
            debugLog("fetchBookmarkedBooks error: \(error)")
            completion([])
            return
        }

        // 알라딘 ItemLookUp으로 카테고리 포함 상세를 가져온다.
        NetworkManager.shared.fetchBookmarkedBooks(isbns: bookmarkedISBNs) { books in
            let mappedBooks = books.map { book -> BookData in
                var updated = book
                updated.isBookmarked = true
                return updated
            }
            completion(mappedBooks)
        }
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
        request.predicate = NSPredicate(format: "isbn13 == %ld AND account == %@", Int64(isbn13), account)

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

    func saveComment(isbn13: Int64, readDate: Date, rating: Double, comment: String) {
        guard let account = fetchCurrentAccount() else { return }
        let entity = Comment(context: context)
        entity.account = account
        entity.isbn13 = isbn13
        entity.readDate = readDate
        entity.rating = rating
        entity.comment = comment
        entity.createdAt = Date()
        saveContext()
    }

    func updateComment(_ comment: Comment, readDate: Date, rating: Double, text: String) {
        comment.readDate = readDate
        comment.rating = rating
        comment.comment = text
        saveContext()
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
