
import UIKit
import Alamofire
import CoreData
import Kingfisher
import SnapKit

class MainViewController: UIViewController {

    private var preferredBooks: [BookData] = []
    private var recentBooks: [BookData] = []
    private var rankedBooks: [Book] = []
    private var bestsellerCache: [BookData] = []
    private var currentBestseller: BookData?
    private let bookCategory = filters

    private var account: Account?
    private var usersChoices: [String] = []

    //    동기화를 위한 lockqueue 추가
    private let bookLockQueue = DispatchQueue(label: "com.readdam.bookdata.lock")

    private let refreshControl = UIRefreshControl()

    // MARK: - 상단바 (Figma처럼 평평하게: iOS 26 바 버튼 글래스를 피하려고 시스템 내비바 대신 사용)
    private let topBar: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "logo_colored"))
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapHomeLogo))
        )
        return imageView
    }()

    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(searchButtonClicked), for: .touchUpInside)
        return button
    }()

    // MARK: - 세로 스크롤 + 스택 (5개 섹션)
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.alwaysBounceVertical = true
        return view
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 24
        return stack
    }()

    private let quoteCard = QuoteCardView()

    private let preferredTitleLabel = MainViewController.sectionTitleLabel()
    private lazy var preferredCollectionView = makeBookCollectionView(tag: Tag.preferred)

    private let likedTitleLabel = MainViewController.sectionTitleLabel("이번주 많은 마음을 받은 책이에요")
    private lazy var likedTitleRow = titleRow(likedTitleLabel)
    private lazy var rankingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.tag = Tag.ranking
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(BookRankingCollectionViewCell.self, forCellWithReuseIdentifier: "BookRankingCollectionViewCell")
        cv.delegate = self
        cv.dataSource = self
        return cv
    }()
    private var rankingHeightConstraint: Constraint?

    private let bestsellerCard = BestsellerCardView()

    private let newBookTitleLabel = MainViewController.sectionTitleLabel("내 책장에 활기를 불어넣을 신간 모음")
    private lazy var recentCollectionView = makeBookCollectionView(tag: Tag.recent)

    private enum Tag {
        static let preferred = 1
        static let recent = 2
        static let ranking = 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        setupRefreshControl()
        bestsellerCard.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapBestseller))
        )
        bestsellerCard.isUserInteractionEnabled = true

        BookRepository.shared.seedDemoRankedBooksIfNeeded()

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleLikeChanged), name: .bookLikeDidChange, object: nil
        )

        fetchAccountAndConfigure()
        fetchRecentBooks()
        loadBestseller()
        loadTopBooks()
    }

    @objc private func handleLikeChanged() {
        loadTopBooks()
    }

    @objc private func didTapHomeLogo() {
        //        홈화면 새로고침: 최상단 이동 + 갱신
        scrollView.setContentOffset(CGPoint(x: 0, y: -scrollView.adjustedContentInset.top), animated: true)
        refreshControl.beginRefreshing()
        quoteCard.showRandomImage()
        handleRefresh()
    }

    @objc private func searchButtonClicked() {
        self.tabBarController?.selectedIndex = 1
    }

    @objc private func didTapBestseller() {
        guard let book = currentBestseller else { return }
        let detailVC = DetailViewController(isbn13: book.isbn13Int)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        quoteCard.showRandomImage()
        loadBestseller()
        refreshHomeIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 로그인 직후 메인 진입 시 인사 토스트 (대기 메시지 있을 때만)
        showPendingToast()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - Data

    private func fetchAccountAndConfigure() {
        guard let account = CoreDataManager.shared.fetchCurrentAccount() else {
            self.account = nil
            updatePreferredTitle()
            usersChoices = ["에세이", "문학"]
            fetchPrefferedBooks(for: usersChoices)
            return
        }
        self.account = account
        updatePreferredTitle()
        configureHome(with: account)
    }

    private func updatePreferredTitle() {
        let nickname = account?.nickname ?? "회원"
        preferredTitleLabel.text = "\(nickname)님, 이런 책은 어떠세요?"
    }

    //    사용자 선호도 기반 홈 구성
    private func configureHome(with account: Account) {
        guard let ageRange = AgeRange(rawValue: account.age),
              let genderRaw = account.gender,
              let gender = Gender(rawValue: genderRaw) else {
            usersChoices = ["에세이", "문학"]
            fetchPrefferedBooks(for: usersChoices)
            return
        }

        let baseGenres = GenreRecommendation.recommendedGenres(
            ageRange: ageRange,
            gender: gender
        )

        let selectedGenres = CoreDataManager.shared.fetchGenres()
        usersChoices = selectedGenres.isEmpty ? baseGenres : selectedGenres

        fetchPrefferedBooks(for: usersChoices)
    }

    //    장르 이름으로 bookfilter 찾기
    private func filter(for genre: String) -> BookFilter? {
        return bookCategory.first { $0.name == genre }
    }

    //    사용자 맞춤 추천 책 가져오기
    private func fetchPrefferedBooks(for genres: [String]) {
        let randomGenres = Array(genres.shuffled().prefix(3))

        guard !randomGenres.isEmpty else {
            DispatchQueue.main.async {
                self.preferredBooks = []
                self.preferredCollectionView.reloadData()
            }
            return
        }

        LoadingManager.shared.showLoading(on: view)

        let group = DispatchGroup()
        var collectedBooks: [[BookData]] = []

        for genre in randomGenres {
            guard let filter = filter(for: genre) else { continue }

            for categoryIdString in filter.categoryIds {
                guard let categoryId = Int(categoryIdString) else { continue }

                group.enter()
                print("무작위 선택: \(genre) (ID: \(categoryId)) 검색 중...")
                NetworkManager.shared.bookLists(
                    queryType: "Bestseller",
                    category: categoryId
                ) { result in
                    defer { group.leave() }

                    let books: [BookData]
                    switch result {
                    case .success(let bookInfo):
                        books = Array(bookInfo.item.prefix(10))
                    case .failure(let error):
                        print("\(genre)(ID: \(categoryId)) 검색 실패: \(error)")
                        books = []
                    }

                    self.bookLockQueue.async {
                        collectedBooks.append(books)
                    }
                }
            }
        }

        group.notify(queue: .main) {
            LoadingManager.shared.hideLoading()
            let allBooks = collectedBooks.flatMap { $0 }
            self.preferredBooks = Array(allBooks.shuffled().prefix(10))
            self.preferredCollectionView.reloadData()
        }
    }

    private func fetchRecentBooks() {
        print("최근 신간 불러오기 - ItemNewAll")
        LoadingManager.shared.showLoading(on: view)

        NetworkManager.shared.bookLists(
            queryType: "ItemNewAll",
            category: 0) { result in
                DispatchQueue.main.async {
                    LoadingManager.shared.hideLoading()

                    switch result {
                    case .success(let newBook):
                        self.recentBooks = Array(newBook.item.prefix(10))
                        self.recentCollectionView.reloadData()
                        print("신간 \(self.recentBooks.count)개 로드 완료")
                    case .failure(let error):
                        print("신간 로드 실패: \(error)")
                        self.recentBooks = []
                        self.recentCollectionView.reloadData()
                        self.showErrorAlert()
                    }
                }
            }
    }

    private func loadBestseller() {
        NetworkManager.shared.bookLists(
            queryType: "Bestseller",
            category: 0
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.handleBestsellerResult(result)
            }
        }
    }

    private func handleBestsellerResult(_ result: Result<BookInfo, AFError>) {
        switch result {
        case .success(let bestsellerBook):
            let items = bestsellerBook.item
            guard let randomBestseller = items.randomElement() else { return }
            bestsellerCache = items
            configureBestseller(with: randomBestseller)

        case .failure(let error):
            print("베스트셀러 실패: \(error)")
            // 캐시가 있으면 그걸로 대체, 없으면 오류 안내
            guard let cachedRandom = bestsellerCache.randomElement() else {
                showErrorAlert()
                return
            }
            configureBestseller(with: cachedRandom)
        }
    }

    private func configureBestseller(with book: BookData) {
        currentBestseller = book
        bestsellerCard.configure(
            coverImage: nil,
            blurImage: nil,
            title: book.title,
            description: book.description.isEmpty ? "베스트셀러 추천 도서입니다!" : book.description
        )
        loadBestsellerImages(book: book)
    }

    private func loadBestsellerImages(book: BookData) {
        let trimmed = book.cover.trimmingCharacters(in: .whitespaces)
        // 표지 없음(빈값/알라딘 noimg) → placeholder, 블러 배경은 생략
        guard !trimmed.isEmpty,
              !trimmed.lowercased().contains("noimg"),
              let coverUrl = URL(string: trimmed) else {
            bestsellerCard.bookCover.setBookCover(nil)   // 회색 배경 + 72x72 중앙 placeholder
            bestsellerCard.blurBackgroundView.image = nil
            return
        }

        let blurOptions: KingfisherOptionsInfo = [
            .processor(BlurImageProcessor(blurRadius: 12)),
            .scaleFactor(UIScreen.main.scale),
        ]
        let sharpOptions: KingfisherOptionsInfo = [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(0.3))
        ]

        bestsellerCard.bookCover.kf.setImage(
            with: coverUrl,
            placeholder: UIImage(named: "placeholder"),
            options: sharpOptions
        )
        bestsellerCard.blurBackgroundView.kf.setImage(
            with: coverUrl,
            options: blurOptions
        )
    }

    private func loadTopBooks() {
        rankedBooks = BookRepository.shared.getTopRankedBooks()
        rankingCollectionView.reloadData()
        updateRankingLayout()
    }

    private func updateRankingLayout() {
        let count = min(rankedBooks.count, 3)
        let hasBooks = count > 0
        likedTitleRow.isHidden = !hasBooks
        rankingCollectionView.isHidden = !hasBooks

        let rowHeight: CGFloat = 112
        let spacing: CGFloat = 20
        let height = hasBooks ? CGFloat(count) * rowHeight + CGFloat(count - 1) * spacing : 0
        rankingHeightConstraint?.update(offset: height)
    }

    private func setupRefreshControl() {
        scrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

    @objc private func handleRefresh() {
        fetchAccountAndConfigure()
        fetchRecentBooks()
        loadBestseller()
        loadTopBooks()
        quoteCard.showRandomImage()
        refreshControl.endRefreshing()
    }

    private func refreshHomeIfNeeded() {
        fetchAccountAndConfigure()
        loadTopBooks()
    }

    // MARK: - Layout

    private func configureUI() {
        view.addSubviews([scrollView, topBar])
        topBar.addSubviews([logoImageView, searchButton])
        scrollView.addSubview(contentStack)

        let bestsellerContainer = makeBestsellerContainer()

        contentStack.addArrangedSubviews([
            quoteCard,
            titleRow(preferredTitleLabel),
            preferredCollectionView,
            likedTitleRow,
            rankingCollectionView,
            bestsellerContainer,
            titleRow(newBookTitleLabel),
            recentCollectionView,
        ])

        contentStack.setCustomSpacing(56, after: quoteCard)
        contentStack.setCustomSpacing(48, after: preferredCollectionView)
        contentStack.setCustomSpacing(62, after: rankingCollectionView)
        contentStack.setCustomSpacing(41, after: bestsellerContainer)

        topBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(48)
        }
        logoImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.equalTo(72)
            make.height.equalTo(28)
        }
        searchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(32)
        }
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(topBar.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        contentStack.snp.makeConstraints { make in
            make.verticalEdges.equalTo(scrollView.contentLayoutGuide)
            make.horizontalEdges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        quoteCard.snp.makeConstraints { make in
            make.height.equalTo(364)
        }
        preferredCollectionView.snp.makeConstraints { make in
            make.height.equalTo(243)
        }
        rankingCollectionView.snp.makeConstraints { make in
            rankingHeightConstraint = make.height.equalTo(376).constraint
        }
        recentCollectionView.snp.makeConstraints { make in
            make.height.equalTo(243)
        }
    }

    private func makeBestsellerContainer() -> UIView {
        let container = UIView()
        container.addSubview(bestsellerCard)
        bestsellerCard.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(354)
            make.height.equalTo(415)
        }
        return container
    }

    private func titleRow(_ label: UILabel) -> UIView {
        let container = UIView()
        container.addSubview(label)
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().inset(24)
            make.verticalEdges.equalToSuperview()
        }
        return container
    }

    private static func sectionTitleLabel(_ text: String = "") -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.customFont(ofSize: 20, weight: .bold)
        label.textColor = .bk1
        label.textAlignment = .left
        return label
    }

    //    가로 스크롤 책 컬렉션뷰
    private func makeBookCollectionView(tag: Int) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.tag = tag
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        cv.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: "MainCollectionViewCell")
        cv.delegate = self
        cv.dataSource = self
        return cv
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
        case Tag.preferred: return preferredBooks.count
        case Tag.recent: return recentBooks.count
        case Tag.ranking: return min(rankedBooks.count, 3)
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == Tag.ranking {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookRankingCollectionViewCell", for: indexPath) as! BookRankingCollectionViewCell
            let book = rankedBooks[indexPath.item]
            cell.bookImage.setBookCover(book.image)
            cell.bookRank.text = "\(indexPath.item + 1)"
            cell.bookTitle.text = book.title
            cell.bookAuthorPublisher.text = "\((book.author ?? "").cleanAuthor()) · \(book.publisher ?? "")"
            cell.showLiked.showLikedCounts(count: Int(book.liked?.likedCount ?? 0))
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        let book = (collectionView.tag == Tag.preferred) ? preferredBooks[indexPath.item] : recentBooks[indexPath.item]
        cell.bookImage.setBookCover(book.cover)
        cell.bookTitle.text = book.title.cleanHTML()
        cell.bookAuthor.text = book.author.cleanAuthor()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == Tag.ranking {
            return CGSize(width: collectionView.bounds.width - 48, height: 112)
        }
        return CGSize(width: 130, height: 243)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let isbn13: Int
        switch collectionView.tag {
        case Tag.preferred:
            guard indexPath.item < preferredBooks.count else { return }
            isbn13 = preferredBooks[indexPath.item].isbn13Int
        case Tag.recent:
            guard indexPath.item < recentBooks.count else { return }
            isbn13 = recentBooks[indexPath.item].isbn13Int
        case Tag.ranking:
            guard indexPath.item < rankedBooks.count else { return }
            isbn13 = rankedBooks[indexPath.item].isbn13Int
        default:
            return
        }
        navigationController?.pushViewController(DetailViewController(isbn13: isbn13), animated: true)
    }
}
