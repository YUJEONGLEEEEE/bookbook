
import UIKit
import Kingfisher
import SnapKit

class LikedViewController: UIViewController {

    private var allLikedBooks: [BookData] = []
    private var likedBooks: [BookData] = []

    private var currentPage = 1
    private var totalResults = 0
    private let itemsPerPage = 30

    private var pageButtons: [UIButton] = []
    private let maxPagesShown = 10

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 24
        layout.minimumInteritemSpacing = 24
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(LikedCollectionViewCell.self, forCellWithReuseIdentifier: "LikedCollectionViewCell")
        // 페이지네이션을 섹션 푸터로 → 결과와 함께 스크롤됨
        view.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: "PaginationFooter"
        )
        view.showsVerticalScrollIndicator = true
        return view
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 마음을 표현한 책이 없어요"
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
        navigationItem.title = "마음서랍"
        collectionView.delegate = self
        collectionView.dataSource = self
        configureUI()
        setupButtonActions()

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleLikeChanged), name: .bookLikeDidChange, object: nil
        )
    }

    @objc private func handleLikeChanged() {
        currentPage = 1
        loadLikedBooks()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPage = 1
        loadLikedBooks()
    }

    private func loadLikedBooks() {
        LoadingManager.shared.showLoading(on: view)
        CoreDataManager.shared.fetchLikedBooks { [weak self] books in
            DispatchQueue.main.async {
                guard let self else { return }
                LoadingManager.shared.hideLoading()
                self.allLikedBooks = books
                self.totalResults = books.count
                self.applyPagination()
                self.updateEmptyState()
            }
        }
    }

    private func applyPagination() {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, allLikedBooks.count)

        if startIndex < endIndex {
            likedBooks = Array(allLikedBooks[startIndex..<endIndex])
        } else {
            likedBooks = []
        }

        collectionView.reloadData()

        let totalPages = max(1, (totalResults + itemsPerPage - 1) / itemsPerPage)
        paginationStackView.isHidden = (totalPages == 1 || totalResults == 0)
        setupPaginationButtons(totalPages: totalPages)
    }

    private func updateEmptyState() {
        let isEmpty = allLikedBooks.isEmpty
        collectionView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
    }

    // MARK: - Pagination Buttons

    private func setupButtonActions() {
        previousButton.removeTarget(nil, action: nil, for: .touchUpInside)
        nextButton.removeTarget(nil, action: nil, for: .touchUpInside)
        previousButton.addTarget(self,
                                 action: #selector(previousPageTapped),
                                 for: .touchUpInside)
        nextButton.addTarget(self,
                             action: #selector(nextPageTapped),
                             for: .touchUpInside)
    }

    private func setupPaginationButtons(totalPages: Int) {
        paginationStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        pageButtons.removeAll()

        let canGoPrevious = currentPage > 1
        previousButton.isEnabled = canGoPrevious
        previousButton.setTitleColor(canGoPrevious ? .bk2 : .bk4, for: .normal)
        paginationStackView.addArrangedSubview(previousButton)

        let startPage = max(1, currentPage - 4)
        let endPage = min(totalPages, startPage + maxPagesShown - 1)

        for page in startPage...endPage {
            let button = UIButton(type: .system)
            button.setTitle("\(page)", for: .normal)
            button.tag = page
            button.setTitleColor(page == currentPage ? .bk1 : .bk3, for: .normal)
            button.titleLabel?.font = page == currentPage
            ? UIFont.customFont(ofSize: 17, weight: .bold)
            : UIFont.customFont(ofSize: 17, weight: .medium)
            button.removeTarget(nil, action: nil, for: .touchUpInside)
            button.addTarget(self,
                             action: #selector(pageButtonTapped(_:)),
                             for: .touchUpInside)
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
        applyPagination()
        scrollToTop()
    }

    @objc private func previousPageTapped() {
        guard currentPage > 1 else { return }
        currentPage -= 1
        applyPagination()
        scrollToTop()
    }
    @objc private func nextPageTapped() {
        let totalPages = max(1, (totalResults + itemsPerPage - 1) / itemsPerPage)
        guard currentPage < totalPages else { return }
        currentPage += 1
        applyPagination()
        scrollToTop()
    }

    private func scrollToTop() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if self.collectionView.numberOfItems(inSection: 0) > 0 {
                self.collectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                                 at: .top,
                                                 animated: false)
            }
        }
    }

    private func configureUI() {
        // paginationStackView는 collectionView 섹션 푸터에 동적으로 담는다(콘텐츠와 함께 스크롤)
        view.addSubviews([collectionView, emptyLabel])
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension LikedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedBooks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedCollectionViewCell", for: indexPath) as! LikedCollectionViewCell
        let book = likedBooks[indexPath.item]
        cell.bookImage.setBookCover(book.cover, coverMode: .scaleAspectFit)
        cell.bookTitle.text = book.title.cleanHTML()
        cell.bookAuthor.text = book.author.cleanAuthor()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let book = likedBooks[indexPath.item]
        let detailVC = DetailViewController(isbn13: book.isbn13Int)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 3
        let spacing: CGFloat = 24
        let width: CGFloat = (collectionView.frame.width - spacing * (itemsPerRow - 1)) / itemsPerRow
        let height: CGFloat = 193

        return CGSize(width: width, height: height)
    }

    // 페이지네이션 푸터: 2페이지 이상일 때만 높이 확보(콘텐츠와 함께 스크롤)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let totalPages = max(1, (totalResults + itemsPerPage - 1) / itemsPerPage)
        guard totalPages > 1 else { return .zero }
        return CGSize(width: collectionView.frame.width, height: 64)   // 상단 24 + 페이지네이션 24 + 하단 16
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "PaginationFooter", for: indexPath
        )
        if paginationStackView.superview !== footer {
            paginationStackView.removeFromSuperview()
            footer.addSubview(paginationStackView)
            paginationStackView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalToSuperview().offset(24)
                make.height.equalTo(24)
            }
        }
        return footer
    }

    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    func collectionView(_ collectionView: UICollectionView,
                        trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let actualIndex = (currentPage - 1) * itemsPerPage + indexPath.item
        guard actualIndex < allLikedBooks.count else { return nil }

        let book = allLikedBooks[actualIndex]

        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }

            self.alertWithCancel(
                message: "이 책을 마음서랍에서 꺼내시겠어요?",
                cancelTitle: "놔두기",
                confirmTitle: "꺼내기",
                successMessage: "마음서랍에서 삭제했어요.",
                okHandler: { [weak self] in
                    guard let self else { return }

                    CoreDataManager.shared.decrementLikeCount(for: book.isbn13Int)

                    self.allLikedBooks.removeAll { $0.isbn13 == book.isbn13 }
                    self.totalResults = self.allLikedBooks.count

                    self.applyPagination()
                    self.updateEmptyState()

                    completion(true)
                }
            )
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
