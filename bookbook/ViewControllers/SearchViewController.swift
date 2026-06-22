
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
    // 찾기 화면은 '전체' 칩 없이 장르칩만 (전체 = 미선택 상태) — Figma
    private var allFilters: [BookFilter] { filters.filter { $0.name != "전체" } }

    private var currentSort: BookSortOption = .accuracy

    private var currentPage = 1
    private var totalResults = 0
    private var isLoading = false
    private var currentQuery = ""

    private var pageButtons: [UIButton] = []
    private let maxPagesShown = 10

    private var resultCollectionViewHeightConstraint: Constraint?

    private var searchTopInitialConstraint: Constraint?   // 초기: safeArea + 48
    private var searchTopResultConstraint: Constraint?    // 결과: 네비바 숨김 → safeArea(=아일랜드 바닥) + 8
    private let initialSearchTopOffset: CGFloat = 8   // 네비바(타이틀) 바로 아래로 검색창 올림
    private let resultSearchTopOffset: CGFloat = 8

    private var lastScrollY: CGFloat = 0
    private var isTabBarHidden = false

    private lazy var searchContainer: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 24
        view.alignment = .center
        view.distribution = .fill
        view.backgroundColor = .bk6
        view.layer.cornerRadius = 32
        view.clipsToBounds = true
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        // safe area가 레이아웃 마진에 더해져 고정 높이(60)와 충돌하는 제약 경고 방지
        view.insetsLayoutMarginsFromSafeArea = false
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
        field.clearButtonMode = .never   // 시스템 클리어 대신 커스텀 X 버튼 사용(Figma 위치/크기 일치)
        return field
    }()

    // Figma: 검색어 옆 24px 원형 X (x258), 시스템 클리어보다 크고 위치 정확
    private let clearButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        button.setImage(UIImage(systemName: "xmark.circle.fill", withConfiguration: config), for: .normal)
        button.tintColor = .bk3
        button.isHidden = true
        return button
    }()

    private let searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "searchbutton")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .bk1
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()

    private let startView = StartSearchView()

    private let genreLabel: UILabel = {
        let label = UILabel()
        label.text = "장르"
        label.font = UIFont.customFont(ofSize: 15, weight: .bold)
        label.textColor = .bk1
        return label
    }()

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
        view.showsVerticalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .never   // 하단 inset 수동 제어(탭바 hide 시 끝까지)
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
                heightDimension: .absolute(104)   // 페이지네이션 24 + 하단 간격 64 + 상단 여백 16
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

    private func bookmarkSwipeConfig(at indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard indexPath.item < searchBooks.count else { return nil }
        let book = searchBooks[indexPath.item]
        let isbn = book.isbn13Int
        let action = UIContextualAction(
            style: .normal,
            title: book.isBookmarked ? "빼기" : "담기"
        ) { _, _, completion in
            CoreDataManager.shared.toggleBookmark(isbn13: isbn, categoryId: 0, book: book)
            completion(true)
        }
        action.image = UIImage(named: "blackshelf")?.withRenderingMode(.alwaysTemplate)
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
        filterView.autoSelectsFirst = false   // 기본 미선택(=전체)
        filterView.allowsDeselect = true      // 선택칩 재탭 시 전체로
        filterView.filters = allFilters
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 초기(검색 전)엔 '찾기' 타이틀 표시, 검색 결과 상태에선 네비바 숨김(검색창이 아일랜드 바로 아래로)
        navigationController?.setNavigationBarHidden(!currentQuery.isEmpty, animated: animated)
        setTabBar(hidden: false, animated: false)   // 진입 시 탭바 노출 상태로
        lastScrollY = resultCollectionView.contentOffset.y
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        setTabBar(hidden: false, animated: false)   // 떠날 때 탭바 복원(다른 화면 영향 방지)
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
        clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        searchField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)
    }
    @objc private func searchTextChanged() {
        clearButton.isHidden = (searchField.text ?? "").isEmpty
    }
    @objc private func clearButtonTapped() {
        searchField.text = nil
        clearButton.isHidden = true
        resetSearchResult()
    }
    @objc private func searchButtonTapped() {
        guard let query = searchField.text, !query.isEmpty else { return }
        currentPage = 1
        resetFilterToAll()
        startSearch(query: query, filter: nil)
        view.endEditing(true)
    }

    private func resetFilterToAll() {
        selectedFilter = nil
        filterView.clearSelection()
    }

    private func startSearch(query: String, filter: BookFilter? = nil) {
        // 진행 중인 요청이 있으면 중복 실행 방지(빠른 연타 시 결과 엉킴 방지)
        guard !isLoading else { return }
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
                    debugLog("검색 실패: \(error)")
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
                        debugLog("필터 \(categoryId) 검색 실패: \(error)")
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            LoadingManager.shared.hideLoading()
            guard let self else { return }

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

            // 페이지 이동 중 빈 응답이 0으로 와도 이전 totalResults 유지(페이지네이션 보존)
            if apiTotalResults > 0 || self.currentPage == 1 {
                self.totalResults = apiTotalResults
            }

            self.resultCollectionView.reloadData()
            self.updateResultCollectionViewHeight()
            self.resultCollectionView.setContentOffset(.zero, animated: false)
            self.lastScrollY = 0
            self.sortView.updateTotalCount(self.totalResults)

            let totalPages = max(1, (self.totalResults + 19) / 20)   // 검색결과 수 기준(포트폴리오: 디자인 그대로)
            self.startView.reloadData(recent: self.recentSearches, popular: self.popularSearches)

            let hasResult = !self.searchBooks.isEmpty
            // 장르 선택/페이지 이동 중 빈 결과면 '검색결과 없음' 전체화면 대신 레이아웃(필터칩·정렬·페이지네이션) 유지
            // → 사용자가 다른 장르/전체/다른 페이지로 빠져나갈 수 있게. (새 검색어 전체검색이 0건일 때만 빈 화면)
            let keepResultLayout = hasResult || self.selectedFilter != nil || (self.currentPage > 1 && self.totalResults > 0)
            self.showSearchResultLayout(hasResult: keepResultLayout)
            self.searchField.resignFirstResponder()

            if keepResultLayout {
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
        // 결과 상태에선 네비바 숨김(검색창이 아일랜드 바로 아래로), 초기엔 표시('찾기' 타이틀)
        navigationController?.setNavigationBarHidden(isResult, animated: true)
        if isResult {
            searchTopInitialConstraint?.deactivate()
            searchTopResultConstraint?.activate()
        } else {
            searchTopResultConstraint?.deactivate()
            searchTopInitialConstraint?.activate()
        }
        UIView.animate(withDuration: 0.25) { self.view.layoutIfNeeded() }
    }

    private func setTabBar(hidden: Bool, animated: Bool = true) {
        guard let tabBar = tabBarController?.tabBar else { return }
        let baseY = tabBar.superview?.bounds.height ?? UIScreen.main.bounds.height
        let targetY = hidden ? baseY : baseY - tabBar.frame.height
        // 탭바 보일 땐 탭바 높이만큼 하단 여백, 숨길 땐 0(콘텐츠가 화면 끝까지)
        let inset: CGFloat = hidden ? 0 : tabBar.frame.height
        isTabBarHidden = hidden
        guard tabBar.frame.origin.y != targetY || resultCollectionView.contentInset.bottom != inset else { return }
        UIView.animate(withDuration: animated ? 0.25 : 0, delay: 0, options: .curveEaseOut) {
            tabBar.frame.origin.y = targetY
            self.resultCollectionView.contentInset.bottom = inset
            self.resultCollectionView.verticalScrollIndicatorInsets.bottom = inset
        }
    }

    private func showInitialLayout() {
        navigationItem.leftBarButtonItem?.customView?.isHidden = false
        setSearchTop(isResult: false)
        startView.isHidden = false
        startView.showEmptyState(false)
        genreLabel.isHidden = true
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
            genreLabel.isHidden = false
            filterView.isHidden = false
            boldSeparator.isHidden = false
            sortView.isHidden = false
            resultCollectionView.isHidden = false
            paginationStackView.isHidden = false
        } else {
            startView.isHidden = false
            startView.showEmptyState(true)
            genreLabel.isHidden = true
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
        clearButton.isHidden = true
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

        // 10페이지 단위 고정 블록 (1~10, 11~20 …) — 현재 페이지가 속한 블록을 보여줌
        let startPage = ((currentPage - 1) / maxPagesShown) * maxPagesShown + 1
        let endPage = min(totalPages, startPage + maxPagesShown - 1)

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
    // currentPage는 jumpToPage가 (로딩 가드 통과 후) 변경 — 핸들러에서 미리 바꾸면 desync
    @objc private func pageButtonTapped(_ sender: UIButton) {
        jumpToPage(sender.tag)
    }
    @objc private func previousPageTapped() {
        if currentPage > 1 { jumpToPage(currentPage - 1) }
    }
    @objc private func nextPageTapped() {
        let totalPages = (totalResults + 19) / 20  // 올림 (검색결과 수 기준)
        if currentPage < totalPages { jumpToPage(currentPage + 1) }
    }

    private func jumpToPage(_ page: Int) {
        guard !currentQuery.isEmpty, !isLoading else { return }
        // selectedFilter가 nil이면 '전체'(장르 미선택) — 그대로 전달(startSearch가 nil=전체 처리)
        currentPage = page
        startSearch(query: currentQuery, filter: selectedFilter)
        // 최상단 스크롤은 startSearch 완료 블록에서 처리(reloadData 직후)
    }

    // MARK: - Search History Management

    // 검색 기록도 계정별로 분리
    private var searchHistoryKey: String { UserSession.scopedKey("searchHistory") }
    private var recentSearchesKey: String { UserSession.scopedKey("recentSearches") }

    // 탈퇴 시 현재 계정의 검색 기록 키 정리 (고아 키 방지)
    static func clearSearchHistory() {
        UserDefaults.standard.removeObject(forKey: UserSession.scopedKey("searchHistory"))
        UserDefaults.standard.removeObject(forKey: UserSession.scopedKey("recentSearches"))
    }

    private func saveSearchHistory() {
        UserDefaults.standard.set(searchHistory, forKey: searchHistoryKey)
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    private func loadSearchHistory() {
        if let savedHistory = UserDefaults.standard.dictionary(forKey: searchHistoryKey) as? [String: Int] {
            searchHistory = savedHistory
        }
        if let savedRecent = UserDefaults.standard.array(forKey: recentSearchesKey) as? [String] {
            recentSearches = savedRecent
        }
        startView.reloadData(recent: recentSearches, popular: popularSearches)
    }

    private func deleteRecentSearch(at index: Int) {
        recentSearches.remove(at: index)
        saveSearchHistory()
        startView.reloadData(recent: recentSearches, popular: popularSearches)
    }

    private let defaultPopularKeywords = ["에세이", "노벨문학상", "자기계발", "한강", "주식"]

    private func updatePopularSearches() {
        // 2회 이상 검색한 내 검색어를 횟수 많은 순으로 우선 채우고,
        // 부족한 칸은 기본 키워드로 보충해 항상 5개를 유지(중복 제외).
        let computed = searchHistory
            .filter { $0.value > 1 }
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
        var result = Array(computed)
        for keyword in defaultPopularKeywords where result.count < 5 && !result.contains(keyword) {
            result.append(keyword)
        }
        popularSearches = result
    }

    private func addSearchQuery(_ query: String) {
        searchHistory[query, default: 0] += 1

        if let index = recentSearches.firstIndex(of: query) {
            recentSearches.remove(at: index)
        }
        recentSearches.insert(query, at: 0)

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

        view.addSubviews([searchContainer, startView, genreLabel, filterView, boldSeparator, sortView, resultCollectionView])
        searchContainer.addArrangedSubviews([searchField, clearButton, searchButton])

        searchContainer.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            searchTopInitialConstraint = make.top.equalTo(view.safeAreaLayoutGuide).offset(initialSearchTopOffset).constraint
            searchTopResultConstraint = make.top.equalTo(view.safeAreaLayoutGuide).offset(resultSearchTopOffset).constraint
            make.height.equalTo(60)
        }
        searchTopResultConstraint?.deactivate()   // 시작은 초기 상태

        searchButton.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        clearButton.snp.makeConstraints { make in
            make.size.equalTo(24)
        }

        startView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(searchContainer.snp.bottom).offset(32)
        }

        genreLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.centerY.equalTo(filterView)
        }
        filterView.snp.makeConstraints { make in
            make.leading.equalTo(genreLabel.snp.trailing).offset(12)
            make.trailing.equalTo(view.safeAreaLayoutGuide)
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
            make.bottom.equalToSuperview()   // 화면 끝까지(탭바 아래) — 탭바 숨기면 콘텐츠가 끝까지 참
        }
    }
}

// MARK: - TabReselectable

extension SearchViewController: TabReselectable {
    func handleTabReselect() {
        resetToInitialScreen()
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text, !query.isEmpty else { return false }
        currentPage = 1
        resetFilterToAll()
        startSearch(query: query, filter: nil)
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
        }

        if !current.isEmpty, new.isEmpty {
            resetSearchResult()
        }
        return true
    }
}

// MARK: - BookFilterProtocol

extension SearchViewController: BookFilterProtocol, BookSortProtocol {

    func bookFilterView(_ view: BookFilterView, didSelectFilter filter: BookFilter) {
        selectedFilter = filter

        if !currentQuery.isEmpty {
            currentPage = 1
            startSearch(query: currentQuery, filter: filter)
        }
    }

    func bookFilterViewDidClearSelection(_ view: BookFilterView) {
        selectedFilter = nil
        guard !currentQuery.isEmpty else { return }
        currentPage = 1
        startSearch(query: currentQuery, filter: nil)
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
        clearButton.isHidden = false
        currentPage = 1
        resetFilterToAll()
        startSearch(query: query, filter: nil)
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

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "PaginationFooter", for: indexPath
        )
        if paginationStackView.superview !== footer {
            footer.addSubview(paginationStackView)
            paginationStackView.snp.remakeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(16)
                make.bottom.equalToSuperview().inset(64)   // 페이지네이션 ~ 푸터(superview) 하단 간격 64
                make.height.equalTo(24)
            }
        }
        return footer
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = searchBooks[indexPath.item]
        // '최근 본 책' 기록은 상세페이지(DetailViewController) 진입 시 일괄 처리
        let detailVC = DetailViewController(isbn13: book.isbn13Int)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === resultCollectionView, !searchBooks.isEmpty else { return }
        let y = scrollView.contentOffset.y
        let dy = y - lastScrollY
        if y <= 0 {
            setTabBar(hidden: false)
        } else if dy > 8 {
            setTabBar(hidden: true)
        } else if dy < -8 {
            setTabBar(hidden: false)
        }
        lastScrollY = y
    }

}
