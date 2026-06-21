
import UIKit
import Alamofire
import CoreData
import Kingfisher
import SnapKit

class BookmarkViewController: UIViewController {

    // MARK: - Properties
    private var allBookmarkedBooks: [BookData] = []  // 전체 북마크
    private var filteredBooks: [BookData] = []       // 필터링된 결과

    private var selectedFilter: BookFilter? = nil
    private var allFilters: [BookFilter] { filters } // 전역 filters 사용
    private var currentPage = 1
    private var totalResults = 0
    private var pageButtons: [UIButton] = []
    private let maxPagesShown = 10
    private let itemsPerPage = 20

    private let filterView = BookFilterView()

    private let separator: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(BookmarkCollectionViewCell.self, forCellWithReuseIdentifier: "BookmarkCollectionViewCell")
        // 페이지네이션을 섹션 푸터로 → 결과와 함께 스크롤됨
        view.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "PaginationFooter"
        )
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = true
        // 검색결과 화면처럼 탭바 아래까지 콘텐츠가 차도록 자동 inset 끔(하단 inset 수동 제어)
        view.contentInsetAdjustmentBehavior = .never
        return view
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 내책장에 담긴 책이 없어요"
        label.font = UIFont.customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk3
        label.textAlignment = .center
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()

    private let paginationStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 20
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
        view.backgroundColor = .customWh
        navigationItem.title = "내책장"

        filterView.delegate = self
        filterView.filters = allFilters
        selectedFilter = allFilters.first  // 기본 "전체" 선택

        collectionView.delegate = self
        collectionView.dataSource = self

        configureUI()
        setupButtonActions()

        // 북마크 변경 시 내책장 동기화
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleBookmarkChanged), name: .bookBookmarkDidChange, object: nil
        )
    }

    @objc private func handleBookmarkChanged() {
        currentPage = 1
        loadBookmarkedBooks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPage = 1
        loadBookmarkedBooks()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // collectionView가 탭바 아래까지 차므로, 푸터(페이지네이션)/마지막 줄이 탭바에 가리지 않게 탭바 높이만큼 하단 여백
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        if collectionView.contentInset.bottom != tabBarHeight {
            collectionView.contentInset.bottom = tabBarHeight
            collectionView.verticalScrollIndicatorInsets.bottom = tabBarHeight
        }
    }

    private func loadBookmarkedBooks() {
        LoadingManager.shared.showLoading(on: view)

        CoreDataManager.shared.fetchBookmarkedBooks { [weak self] books in
            DispatchQueue.main.async {
                LoadingManager.shared.hideLoading()
                self?.allBookmarkedBooks = books
                self?.applyFilter()
            }
        }
    }

    private func applyFilter() {
        if let filter = selectedFilter {
            // 알라딘 categoryName에 장르 키워드 포함 여부로 필터링
            filteredBooks = allBookmarkedBooks.filter { filter.matches(categoryName: $0.categoryName) }
        } else {
            filteredBooks = allBookmarkedBooks
        }

        totalResults = filteredBooks.count
        currentPage = 1
        collectionView.reloadData()

        let totalPages = max(1, (totalResults + itemsPerPage - 1) / itemsPerPage)
        paginationStackView.isHidden = (totalPages == 1 || totalResults == 0)
        setupPaginationButtons(totalPages: totalPages)
        updateEmptyState()
    }

    private func updateEmptyState() {
        let isEmpty = filteredBooks.isEmpty
        collectionView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
    }

    private func setupButtonActions() {
        previousButton.removeTarget(nil, action: nil, for: .touchUpInside)
        nextButton.removeTarget(nil, action: nil, for: .touchUpInside)
        previousButton.addTarget(self, action: #selector(previousPageTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextPageTapped), for: .touchUpInside)
    }

    private func setupPaginationButtons(totalPages: Int) {
        paginationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pageButtons.removeAll()

        let canGoPrevious = currentPage > 1
        previousButton.isEnabled = canGoPrevious
        previousButton.setTitleColor(canGoPrevious ? .bk2 : .bk4, for: .normal)
        paginationStackView.addArrangedSubview(previousButton)

        let startPage = max(1, currentPage - 4)
        let endPage = min(totalPages, startPage + 9)

        for page in startPage...endPage {
            let button = UIButton(type: .system)
            button.setTitle("\(page)", for: .normal)
            button.titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .medium)
            button.tag = page
            button.setTitleColor(page == currentPage ? .bk1 : .bk3, for: .normal)
            button.titleLabel?.font = page == currentPage ?
            UIFont.customFont(ofSize: 17, weight: .bold) :
            UIFont.customFont(ofSize: 17, weight: .medium)
            button.removeTarget(nil, action: nil, for: .touchUpInside)
            button.addTarget(self, action: #selector(pageButtonTapped(_:)), for: .touchUpInside)
            pageButtons.append(button)
            paginationStackView.addArrangedSubview(button)
        }

        let canGoNext = currentPage < totalPages
        nextButton.isEnabled = canGoNext
        nextButton.setTitleColor(canGoNext ? .bk2 : .bk4, for: .normal)
        paginationStackView.addArrangedSubview(nextButton)
    }
    @objc private func pageButtonTapped(_ sender: UIButton) {
        currentPage = sender.tag
        setupPaginationButtons(totalPages: (totalResults + itemsPerPage - 1) / itemsPerPage)
        collectionView.reloadData()
        scrollToTopOfList()
    }
    @objc private func previousPageTapped() {
        if currentPage > 1 {
            currentPage -= 1
            setupPaginationButtons(totalPages: (totalResults + itemsPerPage - 1) / itemsPerPage)
            collectionView.reloadData()
            scrollToTopOfList()
        }
    }
    @objc private func nextPageTapped() {
        let totalPages = (totalResults + itemsPerPage - 1) / itemsPerPage
        if currentPage < totalPages {
            currentPage += 1
            setupPaginationButtons(totalPages: totalPages)
            collectionView.reloadData()
            scrollToTopOfList()
        }
    }

    // 페이지 변경 후 최상단으로 (reloadData 직후 레이아웃 강제 → 타이밍 핵 없이 즉시)
    private func scrollToTopOfList() {
        collectionView.layoutIfNeeded()
        collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.adjustedContentInset.top), animated: false)
    }

    private func configureUI() {
        // paginationStackView는 collectionView 섹션 푸터에 동적으로 담는다(콘텐츠와 함께 스크롤)
        view.addSubviews([filterView, separator, collectionView, emptyLabel])

        filterView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(40)
        }

        separator.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(filterView.snp.bottom).offset(12)
        }

        collectionView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(32)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalToSuperview()   // 검색결과처럼 탭바 아래까지 콘텐츠가 참
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }

    }

}

// MARK: - BookFilterProtocol
extension BookmarkViewController: BookFilterProtocol {
    func bookFilterView(_ view: BookFilterView, didSelectFilter filter: BookFilter) {
        selectedFilter = filter
        currentPage = 1
        applyFilter()
    }
}

// MARK: - TabReselectable
extension BookmarkViewController: TabReselectable {
    // 내책장 탭 재탭 → 1페이지로 + 리로드 + 최상단
    func handleTabReselect() {
        currentPage = 1
        applyFilter()
        collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.contentInset.top), animated: true)
    }
}

// MARK: - UICollectionView
extension BookmarkViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, filteredBooks.count)
        return max(0, endIndex - startIndex)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkCollectionViewCell", for: indexPath) as! BookmarkCollectionViewCell

        let actualIndex = (currentPage - 1) * itemsPerPage + indexPath.item
        guard actualIndex < filteredBooks.count else { return cell }

        let book = filteredBooks[actualIndex]

        cell.bookImage.setBookCover(book.cover)
        cell.bookTitle.text = book.title
        cell.authorLabel.text = book.author.cleanAuthor()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let actualIndex = (currentPage - 1) * itemsPerPage + indexPath.item
        guard actualIndex < filteredBooks.count else { return }

        let book = filteredBooks[actualIndex]
        let detailVC = DetailViewController(isbn13: book.isbn13Int)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columnSpacing: CGFloat = 20
        let width = (collectionView.frame.width - columnSpacing) / 2
        let height: CGFloat = 318  // 고정 높이 (이미지 239 + 텍스트)
        return CGSize(width: width, height: height)
    }

    // 페이지네이션 푸터: 2페이지 이상일 때만 높이 확보(콘텐츠와 함께 스크롤)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let totalPages = max(1, (totalResults + itemsPerPage - 1) / itemsPerPage)
        guard totalPages > 1 else { return .zero }
        return CGSize(width: collectionView.frame.width, height: 88)   // 상단 여백 24 + 페이지네이션 48 + 하단 16
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "PaginationFooter", for: indexPath
        )
        // 단일 paginationStackView 인스턴스를 푸터로 이동
        if paginationStackView.superview !== footer {
            paginationStackView.removeFromSuperview()
            footer.addSubview(paginationStackView)
            paginationStackView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(24)
                make.height.equalTo(48)
            }
        }
        return footer
    }

    // MARK: - 북마크 취소 (롱프레스 컨텍스트 메뉴 → 알럿)
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let actualIndex = (currentPage - 1) * itemsPerPage + indexPath.item
        guard actualIndex < filteredBooks.count else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let cancelBookmark = UIAction(
                title: "내책장에서 빼기",
                image: UIImage(named: "blackshelf")?
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(.customAlert, renderingMode: .alwaysOriginal),
                attributes: .destructive
            ) { _ in
                self?.confirmDeleteBookmark(at: actualIndex)
            }
            return UIMenu(children: [cancelBookmark])
        }
    }

    private func confirmDeleteBookmark(at index: Int) {
        guard index < filteredBooks.count else { return }
        let book = filteredBooks[index]

        presentCustomAlert(
            message: "이 책을 내 책장에서 빼시겠어요?",
            actions: [
                CustomAlertAction(title: "빼기", titleColor: .bk2, handler: { [weak self] in
                    guard let self else { return }
                    CoreDataManager.shared.deleteBookmark(isbn13: book.isbn13Int)
                    self.allBookmarkedBooks.removeAll { $0.isbn13 == book.isbn13 }
                    self.applyFilter()
                    self.showAlert(message: "내 책장에 담기를 취소했어요.")
                }),
                CustomAlertAction(title: "유지하기", titleColor: .customBtn, handler: nil)
            ]
        )
    }

}
