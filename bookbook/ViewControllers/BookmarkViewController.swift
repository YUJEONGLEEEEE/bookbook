
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
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = true
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
        }
    }
    @objc private func previousPageTapped() {
        if currentPage > 1 {
            currentPage -= 1
            setupPaginationButtons(totalPages: (totalResults + itemsPerPage - 1) / itemsPerPage)
            collectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    @objc private func nextPageTapped() {
        let totalPages = (totalResults + itemsPerPage - 1) / itemsPerPage
        if currentPage < totalPages {
            currentPage += 1
            setupPaginationButtons(totalPages: totalPages)
            collectionView.reloadData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: false)
            }
        }
    }

    private func configureUI() {
        view.addSubviews([filterView, separator, collectionView, emptyLabel, paginationStackView])

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
            make.bottom.equalTo(paginationStackView.snp.top).offset(-80)
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }

        paginationStackView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(64)
            make.centerX.equalToSuperview()
            make.height.equalTo(48)
            make.bottom.equalToSuperview().inset(24)
        }
    }

}

// MARK: - BookFilterProtocol
extension BookmarkViewController: BookFilterProtocol {
    func bookFilterView(_ view: BookFilterView, didSelectFilter filter: BookFilter) {
        print("북마크 필터 선택: \(filter.name)")
        selectedFilter = filter
        currentPage = 1
        applyFilter()
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

    // MARK: - 북마크 취소 (롱프레스 컨텍스트 메뉴 → 알럿)
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let actualIndex = (currentPage - 1) * itemsPerPage + indexPath.item
        guard actualIndex < filteredBooks.count else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let cancelBookmark = UIAction(
                title: "북마크 취소",
                image: UIImage(systemName: "bookmark.slash"),
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
