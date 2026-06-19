
import UIKit
import Alamofire
import Kingfisher
import SnapKit

class SearchViewController: UIViewController {

    private var searchHistory: [String: Int] = [:]
    private var recentSearches: [String] = []
    private var popularSearches: [String] = []
    private var searchBooks: [BookData] = []

    private var selectedFilter: BookFilter? = nil
    private var allFilters: [BookFilter] { filters }

    private var currentSort: BookSortOption = .accuracy

    private var currentPage = 1
    private var totalResults = 0
    private var isLoading = false
    private var currentQuery = ""

    private var pageButtons: [UIButton] = []
    private let maxPagesShown = 10

    private var resultCollectionViewHeightConstraint: Constraint?

    private var searchTopInitialConstraint: Constraint?   // 초기: safeArea 기준
    private var searchTopResultConstraint: Constraint?    // 결과: superview 기준(위로 당김)
    private let initialSearchTopOffset: CGFloat = 48
    private let resultSearchTopOffset: CGFloat = 80

    private lazy var searchContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 16
        view.alignment = .center
        view.distribution = .fill
        view.backgroundColor = .bk6
        view.layer.cornerRadius = 30
        view.clipsToBounds = true
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        return view
    }()

    private let searchField: UITextField = {
        let field = UITextField()
        field.attributedPlaceholder = NSAttributedString(
            string: "검색어를 입력해주세요",
            attributes: [
                .foregroundColor: UIColor.bk3,
                .font: UIFont.customFont(ofSize: 20, weight: .medium)
            ]
        )
        field.font = UIFont.customFont(ofSize: 20, weight: .medium)
        field.textColor = .bk1
        field.textAlignment = .left
        field.backgroundColor = .clear
        field.returnKeyType = .search
        field.autocorrectionType = .no
        field.spellCheckingType = .yes
        field.clearButtonMode = .whileEditing
        return field
    }()

    private let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "searchbutton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .bk1
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    private let startView = StartSearchView()

    private let filterView = BookFilterView()

    private let boldSeparator: UIView = {
        let view = UIView()
        view.addBolderLine()
        return view
    }()

    private let sortView = BookSortView()

    private lazy var resultCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeResultLayout())
        view.backgroundColor = .white
        view.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "SearchCollectionViewCell")
        view.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "PaginationFooter"
        )
        view.alwaysBounceVertical = true
        view.isHidden = true
        return view
    }()

    // list 레이아웃 사용 (FlowLayout은 스와이프 액션 미지원)
    private func makeResultLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { [weak self] _, env in
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
            config.showsSeparators = false
            config.backgroundColor = .clear
            config.leadingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                self?.bookmarkSwipeConfig(at: indexPath)
            }
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: env)
            section.interGroupSpacing = 20
            section.contentInsets = .zero
            // 페이지네이션을 섹션 푸터로 → 결과와 함께 스크롤됨
            let footerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(56)
            )
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: footerSize,
                elementKind: UICollectionView.elementKindSectionFooter,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [footer]
            return section
        }
    }

    // 스와이프 → 북마크 등록/해제
    private func bookmarkSwipeConfig(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.item < searchBooks.count else { return nil }
        let book = searchBooks[indexPath.item]
        let isbn = book.isbn13Int
        let action = UIContextualAction(
            style: .normal,
            title: book.isBookmarked ? "빼기" : "담기"
        ) { _, _, completion in
            CoreDataManager.shared.toggleBookmark(isbn13: isbn, categoryId: 0)
            completion(true)
        }
        action.image = UIImage(systemName: "bookmark.fill")
        action.backgroundColor = .customMain
        let configuration = UISwipeActionsConfiguration(actions: [action])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }

    private let paginationStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.distribution = .fillEqually
        view.alignment = .center
        view.isHidden = true
        return view
    }()

    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("<", for: .normal)
        button.setTitleColor(.bk2, for: .normal)
        button.titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .semibold)
        return button
    }()

    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(">", for: .normal)
        button.setTitleColor(.bk2, for: .normal)
        button.titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .semibold)
        return button
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        customNavigationTitle()

        searchField.delegate = self
        filterView.delegate = self
        filterView.filters = allFilters
        selectedFilter = allFilters.first
        sortView.delegate = self
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
        startView.delegate = self

        searchAction()
        setupKeyboardDismissMode()
        configureUI()
        loadSearchHistory()
        loadPopularSearches()
        showInitialLayout()

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleBookStateChanged), name: .bookLikeDidChange, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleBookStateChanged), name: .bookBookmarkDidChange, object: nil
        )
    }

    @objc private func handleBookStateChanged() {
        guard !searchBooks.isEmpty else { return }
        CoreDataManager.shared.applyLikedCount(to: &searchBooks)
        CoreDataManager.shared.applyBookmarkStatus(to: &searchBooks)
        resultCollectionView.reloadData()
    }

    private func customNavigationTitle() {
        let title = UILabel()
        title.text = "찾기"
        title.font = UIFont.customFont(ofSize: 24, weight: .bold)
        title.textColor = .bk1
        title.isUserInteractionEnabled = false
        let item = UIBarButtonItem(customView: title)
        // iOS 26: 바 버튼 글래스 배경 제거
        if #available(iOS 26.0, *) {
            item.hidesSharedBackground = true
        }
        navigationItem.leftBarButtonItem = item
    }

    private func searchAction() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }
    @objc private func searchButtonTapped() {
        print(#function)
        guard let query = searchField.text, !query.isEmpty else { return }
        currentPage = 1
        startSearch(query: query, filter: selectedFilter)
        view.endEditing(true)
    }

    private func startSearch(query: String, filter: BookFilter? = nil) {
        print("검색 시작: \(query), 필터: \(filter?.name ?? "전체"), 페이지: \(currentPage), 정렬: \(currentSort)")
        LoadingManager.shared.showLoading(on: view)

        currentQuery = query
        searchBooks.removeAll()
        isLoading = true
        selectedFilter = filter

        let group = DispatchGroup()
        var allResults: [BookData] = []
        var apiTotalResults: Int = 0

        let categoryIds: [String] = {
            guard let filter else { return [] }
            if filter.name == "전체" { return [] }
            return filter.categoryIds
        }()

        if categoryIds.isEmpty {
            group.enter()
            NetworkManager.shared.searchBooks(
                query: query,
                category: nil,
                sort: currentSort,
                page: currentPage
            ) { result in
                defer { group.leave() }
                switch result {
                case .success(let bookInfo):
                    allResults.append(contentsOf: bookInfo.item)
                    apiTotalResults = bookInfo.totalResults
                case .failure(let error):
                    print("검색 실패: \(error)")
                }
            }
        } else {
            for categoryIdString in categoryIds {
                guard let categoryId = Int(categoryIdString) else { continue }

                group.enter()
                NetworkManager.shared.searchBooks(
                    query: query,
                    category: categoryId,
                    sort: currentSort,
                    page: currentPage
                ) { result in
                    defer { group.leave() }
                    switch result {
                    case .success(let bookInfo):
                        allResults.append(contentsOf: bookInfo.item)
                        apiTotalResults = max(apiTotalResults, bookInfo.totalResults)
                    case .failure(let error):
                        print("필터 \(categoryId) 검색 실패: \(error)")
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            LoadingManager.shared.hideLoading()
            guard let self else { return }

//            ISBN 기준 중복 제거
            var seen = Set<String>()
            self.searchBooks = allResults.filter { book in
                if seen.contains(book.isbn13) { return false }
                seen.insert(book.isbn13,)
                return true
            }

            CoreDataManager.shared.applyLikedCount(to: &self.searchBooks)
            CoreDataManager.shared.applyBookmarkStatus(to: &self.searchBooks)

            // 추천순: 좋아요 누적순 우선, 동률(보통 0)이면 API 판매량(SalesPoint) 순서 유지 (안정 정렬)
            if self.currentSort == .recommend {
                self.searchBooks = self.searchBooks.enumerated()
                    .sorted { lhs, rhs in
                        lhs.element.likedCount != rhs.element.likedCount
                            ? lhs.element.likedCount > rhs.element.likedCount
                            : lhs.offset < rhs.offset
                    }
                    .map { $0.element }
            }

            self.totalResults = apiTotalResults

            self.resultCollectionView.reloadData()
            self.updateResultCollectionViewHeight()
            self.sortView.updateTotalCount(self.totalResults)

            let totalPages = max(1, (self.totalResults + 19) / 20)
            self.startView.reloadData(recent: self.recentSearches, popular: self.popularSearches)

            let hasResult = !self.searchBooks.isEmpty
            self.showSearchResultLayout(hasResult: hasResult)
            self.searchField.resignFirstResponder()

            if hasResult {
                self.setupPaginationButtons(totalPages: totalPages)
            } else {
                self.paginationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            }
            self.addSearchQuery(query)
            self.isLoading = false
        }
    }

    private func updateResultCollectionViewHeight() {
        let cellHeight: CGFloat = 123
        let lineSpacing: CGFloat = 20
        let maxVisibleCount = 4
        let visibleCount = min(searchBooks.count, maxVisibleCount)

        let height: CGFloat
        if visibleCount == 0 {
            height = 0
        } else {
            height = CGFloat(visibleCount) * cellHeight + CGFloat(max(0, visibleCount - 1)) * lineSpacing
        }
        resultCollectionViewHeightConstraint?.update(offset: height)
        view.layoutIfNeeded()
    }

    // MARK: - Layout Management

    private func setSearchTop(isResult: Bool) {
        if isResult {
            searchTopInitialConstraint?.deactivate()
            searchTopResultConstraint?.activate()
        } else {
            searchTopResultConstraint?.deactivate()
            searchTopInitialConstraint?.activate()
        }
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    private func showInitialLayout() {
        navigationItem.leftBarButtonItem?.customView?.isHidden = false
        setSearchTop(isResult: false)
        startView.isHidden = false
        startView.showEmptyState(false)
        filterView.isHidden = true
        boldSeparator.isHidden = true
        sortView.isHidden = true
        resultCollectionView.isHidden = true
        paginationStackView.isHidden = true
        updateResultCollectionViewHeight()
    }

    private func showSearchResultLayout(hasResult: Bool) {
        navigationItem.leftBarButtonItem?.customView?.isHidden = true
        setSearchTop(isResult: true)

        if hasResult {
            startView.isHidden = true
            filterView.isHidden = false
            boldSeparator.isHidden = false
            sortView.isHidden = false
            resultCollectionView.isHidden = false
            paginationStackView.isHidden = false
        } else {
            startView.isHidden = false
            startView.showEmptyState(true)
            filterView.isHidden = true
            boldSeparator.isHidden = true
            sortView.isHidden = true
            resultCollectionView.isHidden = true
            paginationStackView.isHidden = true
        }
    }

    private func resetSearchResult() {
        currentQuery = ""
        currentPage = 1
        totalResults = 0
        searchBooks.removeAll()
        resultCollectionView.reloadData()
        updateResultCollectionViewHeight()
        showInitialLayout()
    }

    func resetToInitialScreen() {
        guard isViewLoaded else { return }
        searchField.text = nil
        searchField.resignFirstResponder()
        resetSearchResult()
    }

    // MARK: - pagination

    private func setupPaginationButtons(totalPages: Int) {
        paginationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pageButtons.removeAll()

        let canGoPrevious = currentPage > 1
        previousButton.isEnabled = canGoPrevious
        previousButton.setTitleColor(canGoPrevious ? .bk2 : .bk4, for: .normal)
        previousButton.removeTarget(nil, action: nil, for: .allEvents)
        previousButton.addTarget(self, action: #selector(previousPageTapped), for: .touchUpInside)
        paginationStackView.addArrangedSubview(previousButton)

        let startPage = max(1, currentPage - 4)
        let endPage = min(totalPages, startPage + 9)

        guard startPage <= endPage else { return }

        for page in startPage...endPage {
            let button = UIButton(type: .system)
            button.setTitle("\(page)", for: .normal)
            button.titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .medium)
            button.tag = page

            if page == currentPage {
                button.titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .bold)
                button.setTitleColor(.bk1, for: .normal)
            } else {
                button.titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .medium)
                button.setTitleColor(.bk3, for: .normal)
            }
            button.addTarget(self, action: #selector(pageButtonTapped(_:)), for: .touchUpInside)
            pageButtons.append(button)
            paginationStackView.addArrangedSubview(button)
        }

        let canGoNext = currentPage < totalPages
        nextButton.isEnabled = canGoNext
        nextButton.setTitleColor(canGoNext ? .bk2 : .bk4, for: .normal)
        nextButton.removeTarget(nil, action: nil, for: .allEvents)
        nextButton.addTarget(self, action: #selector(nextPageTapped), for: .touchUpInside)
        paginationStackView.addArrangedSubview(nextButton)
    }
    @objc private func pageButtonTapped(_ sender: UIButton) {
        currentPage = sender.tag
        jumpToPage(currentPage)
    }
    @objc private func previousPageTapped() {
        if currentPage > 1 {
            currentPage -= 1
            jumpToPage(currentPage)
        }
    }
    @objc private func nextPageTapped() {
        let totalPages = (totalResults + 19) / 20  // 올림
        if currentPage < totalPages {
            currentPage += 1
            jumpToPage(currentPage)
        }
    }

    private func jumpToPage(_ page: Int) {
        guard !currentQuery.isEmpty else { return }
        guard let filter = selectedFilter else { return }
        currentPage = page
        isLoading = true
        startSearch(query: currentQuery, filter: filter)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if self.searchBooks.count > 0 {
                self.resultCollectionView.scrollToItem(
                    at: IndexPath(item: 0, section: 0),
                    at: .top,
                    animated: false
                )
            }
        }
    }

    // MARK: - Search History Management

    private func saveSearchHistory() {
        UserDefaults.standard.set(searchHistory, forKey: "searchHistory")
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }

    private func loadSearchHistory() {
        if let savedHistory = UserDefaults.standard.dictionary(forKey: "searchHistory") as? [String: Int] {
            searchHistory = savedHistory
        }
        if let savedRecent = UserDefaults.standard.array(forKey: "recentSearches") as? [String] {
            recentSearches = savedRecent
        }
        startView.reloadData(recent: recentSearches, popular: popularSearches)
    }

    private func deleteRecentSearch(at index: Int) {
        recentSearches.remove(at: index)
        saveSearchHistory()
        startView.reloadData(recent: recentSearches, popular: popularSearches)
        print("최근검색어 삭제: \(index)")
    }

    // 기본 인기 키워드
    private let defaultPopularKeywords = ["수능특강", "노벨문학상", "자기계발", "한강", "주식"]

    private func updatePopularSearches() {
        let computed = searchHistory
            .filter { $0.value > 1 }
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
        popularSearches = computed.isEmpty ? defaultPopularKeywords : Array(computed)
    }

    private func addSearchQuery(_ query: String) {
        searchHistory[query, default: 0] += 1

        // 최근검색어 중복 제거 후 앞으로 이동
        if let index = recentSearches.firstIndex(of: query) {
            recentSearches.remove(at: index)
        }
        recentSearches.insert(query, at: 0)

        // 최근검색어 5개 제한
        if recentSearches.count > 5 {
            recentSearches.removeLast()
        }

        updatePopularSearches()
        saveSearchHistory()
        startView.reloadData(recent: recentSearches, popular: popularSearches)
    }

    private func loadPopularSearches() {
        updatePopularSearches()
        startView.reloadData(recent: recentSearches, popular: popularSearches)
    }

    private func configureUI() {

        view.addSubviews([searchContainer, startView, filterView, boldSeparator, sortView, resultCollectionView])
        searchContainer.addArrangedSubviews([searchField, searchButton])

        searchContainer.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            searchTopInitialConstraint = make.top.equalTo(view.safeAreaLayoutGuide).offset(initialSearchTopOffset).constraint
            searchTopResultConstraint = make.top.equalToSuperview().offset(resultSearchTopOffset).constraint
            make.height.equalTo(60)
        }
        searchTopResultConstraint?.deactivate()   // 시작은 초기 상태

        searchButton.snp.makeConstraints { make in
            make.size.equalTo(24)
        }

        startView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(searchContainer.snp.bottom).offset(32)
        }

        filterView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(searchContainer.snp.bottom).offset(24)
            make.height.equalTo(33)
        }

        boldSeparator.snp.makeConstraints { make in
            make.top.equalTo(filterView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
        }

        sortView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(boldSeparator.snp.bottom).offset(24)
            make.height.equalTo(17)
        }

        resultCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(sortView.snp.bottom).offset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text, !query.isEmpty else { return false }
        currentPage = 1
        startSearch(query: query, filter: selectedFilter)
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField.text ?? "").isEmpty {
            resetSearchResult()
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let current = textField.text ?? ""
        let new = (current as NSString).replacingCharacters(in: range, with: string)

        if current.isEmpty && !new.isEmpty {
            startView.isHidden = true
            print("검색어 입력 시작")
        }

        if !current.isEmpty, new.isEmpty {
            resetSearchResult()
            print("검색결과 초기화")
        }
        return true
    }
}

// MARK: - BookFilterProtocol

extension SearchViewController: BookFilterProtocol, BookSortProtocol {

    func bookFilterView(_ view: BookFilterView, didSelectFilter filter: BookFilter) {
        print("필터 선택: \(filter.name)")
        selectedFilter = filter

        if !currentQuery.isEmpty {
            currentPage = 1
            startSearch(query: currentQuery, filter: filter)
        }
    }

    func sortView(_ view: BookSortView, didSelect sort: BookSortOption) {
        currentSort = sort

        guard !currentQuery.isEmpty else { return }
        currentPage = 1
        startSearch(query: currentQuery, filter: selectedFilter)
    }
}

extension SearchViewController: StartSearchProtocol {
    func startSearchView(_ view: StartSearchView, didSelectQuery query: String) {
        searchField.text = query
        currentPage = 1
        startSearch(query: query, filter: selectedFilter)
    }

    func didDeleteRecentSearch(at index: Int) {
        deleteRecentSearch(at: index)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchBooks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as! SearchCollectionViewCell
        let book = searchBooks[indexPath.item]

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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 123)
    }

    // 페이지네이션을 섹션 푸터에 담아 결과 목록과 함께 스크롤되도록 함
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "PaginationFooter", for: indexPath
        )
        if paginationStackView.superview !== footer {
            footer.addSubview(paginationStackView)
            paginationStackView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(16)
                make.centerY.equalToSuperview()
                make.height.equalTo(24)
            }
        }
        return footer
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        let book = searchBooks[indexPath.item]
        // 최근 검색한 책 기록
        RecentSearchStore.add(RecentBook(
            isbn13: book.isbn13, title: book.title, author: book.author,
            publisher: book.publisher, cover: book.cover, description: book.description
        ))
        let detailVC = DetailViewController(isbn13: book.isbn13Int)
        navigationController?.pushViewController(detailVC, animated: true)
    }

}
