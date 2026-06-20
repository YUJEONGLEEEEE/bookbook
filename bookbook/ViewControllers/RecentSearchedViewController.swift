
import UIKit
import Kingfisher
import SnapKit

// MARK: - 최근 검색한 책 저장소 (UserDefaults)
struct RecentBook: Codable {
    let isbn13: String
    let title: String
    let author: String
    let publisher: String
    let cover: String
    let description: String
}

enum RecentSearchStore {
    private static let key = "recentSearchedBooks"
    // 최근 검색한 책 최대 10개 보관
    private static let limit = 10

    static func all() -> [RecentBook] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let list = try? JSONDecoder().decode([RecentBook].self, from: data) else { return [] }
        return list
    }

    static func add(_ book: RecentBook) {
        var list = all()
        list.removeAll { $0.isbn13 == book.isbn13 }
        list.insert(book, at: 0)
        if list.count > limit { list = Array(list.prefix(limit)) }
        save(list)
    }

    static func remove(isbn13: String) {
        var list = all()
        list.removeAll { $0.isbn13 == isbn13 }
        save(list)
    }

    private static func save(_ list: [RecentBook]) {
        if let data = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

class RecentSearchedViewController: UIViewController {

    private var books: [BookData] = []

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        view.backgroundColor = .clear
        view.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "SearchCollectionViewCell")
        view.alwaysBounceVertical = true
        return view
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 검색한 책이 없어요"
        label.font = UIFont.customFont(ofSize: 16, weight: .medium)
        label.textColor = .bk3
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWh
        navigationItem.title = "최근 검색한 책"
        collectionView.delegate = self
        collectionView.dataSource = self
        configureUI()

        NotificationCenter.default.addObserver(self, selector: #selector(handleStateChanged), name: .bookLikeDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleStateChanged), name: .bookBookmarkDidChange, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBooks()
    }

    @objc private func handleStateChanged() {
        guard !books.isEmpty else { return }
        CoreDataManager.shared.applyLikedCount(to: &books)
        CoreDataManager.shared.applyBookmarkStatus(to: &books)
        collectionView.reloadData()
    }

    private func loadBooks() {
        var list = RecentSearchStore.all().map { r in
            BookData(title: r.title, author: r.author, pubDate: "",
                     description: r.description, isbn13: r.isbn13,
                     cover: r.cover, publisher: r.publisher)
        }
        CoreDataManager.shared.applyLikedCount(to: &list)
        CoreDataManager.shared.applyBookmarkStatus(to: &list)
        books = list
        collectionView.reloadData()
        updateEmptyState()
    }

    private func updateEmptyState() {
        let isEmpty = books.isEmpty
        emptyLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    private func configureUI() {
        view.addSubviews([collectionView, emptyLabel])
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    // 검색 결과와 동일하게 list 레이아웃 + 좌우 스와이프
    private func makeLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] _, env in
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.showsSeparators = false
            config.backgroundColor = .clear
            config.leadingSwipeActionsConfigurationProvider = { [weak self] ip in self?.bookmarkSwipe(at: ip) }
            config.trailingSwipeActionsConfigurationProvider = { [weak self] ip in self?.removeSwipe(at: ip) }
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
            section.interGroupSpacing = 20
            section.contentInsets = .zero
            return section
        }
    }

    // 왼쪽 스와이프 → 북마크 등록/해제
    private func bookmarkSwipe(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.item < books.count else { return nil }
        let book = books[indexPath.item]
        let isbn = book.isbn13Int
        let action = UIContextualAction(style: .normal, title: book.isBookmarked ? "빼기" : "담기") { _, _, done in
            CoreDataManager.shared.toggleBookmark(isbn13: isbn, categoryId: 0)
            done(true)
        }
        action.image = UIImage(named: "blackshelf")?.withRenderingMode(.alwaysTemplate)
        action.backgroundColor = .customMain
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = true
        return config
    }

    // 오른쪽 스와이프 → 최근 검색한 책 리스트에서 삭제
    private func removeSwipe(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.item < books.count else { return nil }
        let isbn = books[indexPath.item].isbn13
        let action = UIContextualAction(style: .normal, title: "삭제") { [weak self] _, _, done in
            guard let self else { done(false); return }
            RecentSearchStore.remove(isbn13: isbn)
            self.books.removeAll { $0.isbn13 == isbn }
            self.collectionView.reloadData()
            self.updateEmptyState()
            done(true)
        }
        action.image = UIImage(systemName: "trash.fill")
        action.backgroundColor = .systemRed
        let config = UISwipeActionsConfiguration(actions: [action])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

extension RecentSearchedViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as! SearchCollectionViewCell
        let book = books[indexPath.item]

        cell.bookImage.setBookCover(book.cover, coverMode: .scaleAspectFit)
        cell.bookTitle.text = book.title.isEmpty ? "" : book.title.cleanHTML()
        let author = book.author.isEmpty ? "" : book.author.cleanAuthor()
        let publisher = book.publisher.isEmpty ? "" : book.publisher.cleanHTML()
        cell.subLabel.text = "\(author) · \(publisher)"
        cell.descriptionLabel.text = book.description.isEmpty ? "" : book.description.cleanHTML()
        cell.showLiked.showLikedCounts(count: book.likedCount)
        cell.bookmarked.isHidden = !book.isBookmarked
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = books[indexPath.item]
        let detailVC = DetailViewController(isbn13: book.isbn13Int)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
