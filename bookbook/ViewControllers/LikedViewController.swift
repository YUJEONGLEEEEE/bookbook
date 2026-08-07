
import UIKit
import SnapKit

class LikedViewController: UIViewController {

    private var allLikedBooks: [BookData] = []
    private var likedBooks: [BookData] = []

    private var currentPage = 1
    private var totalResults = 0
    private let itemsPerPage = 30

    private var pageButtons: [UIButton] = []
    private let maxPagesShown = 5

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 24
        layout.minimumInteritemSpacing = 24
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(LikedCollectionViewCell.self)
        view.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: UICollectionView.paginationFooter
        )
        view.showsVerticalScrollIndicator = true
        return view
    }()

    private let emptyLabel = UILabel.emptyStateLabel(text: "아직 마음을 표현한 책이 없어요", size: 17)

    private let paginationStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 20
        view.distribution = .fillEqually
        view.alignment = .center
        view.isHidden = true
        return view
    }()

    private let previousBlockButton = UIButton.paginationArrow()

    private let previousButton = UIButton.paginationArrow()

    private let nextButton = UIButton.paginationArrow()

    private let nextBlockButton = UIButton.paginationArrow()

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
        let totalPages = max(1, (totalResults + itemsPerPage - 1) / itemsPerPage)
        currentPage = min(max(1, currentPage), totalPages)
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, allLikedBooks.count)

        if startIndex < endIndex {
            likedBooks = Array(allLikedBooks[startIndex..<endIndex])
        } else {
            likedBooks = []
        }

        collectionView.reloadData()

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
        previousBlockButton.removeTarget(nil, action: nil, for: .touchUpInside)
        previousButton.removeTarget(nil, action: nil, for: .touchUpInside)
        nextButton.removeTarget(nil, action: nil, for: .touchUpInside)
        nextBlockButton.removeTarget(nil, action: nil, for: .touchUpInside)
        previousBlockButton.addTarget(self,
                                      action: #selector(previousBlockTapped),
                                      for: .touchUpInside)
        previousButton.addTarget(self,
                                 action: #selector(previousPageTapped),
                                 for: .touchUpInside)
        nextButton.addTarget(self,
                             action: #selector(nextPageTapped),
                             for: .touchUpInside)
        nextBlockButton.addTarget(self,
                                  action: #selector(nextBlockTapped),
                                  for: .touchUpInside)
    }

    private func setupPaginationButtons(totalPages: Int) {
        PaginationBar.render(
            stackView: paginationStackView,
            previousBlockButton: previousBlockButton,
            previousButton: previousButton,
            nextButton: nextButton,
            nextBlockButton: nextBlockButton,
            pageButtons: &pageButtons,
            currentPage: currentPage,
            totalPages: totalPages,
            maxPagesShown: maxPagesShown,
            availableWidth: view.bounds.width,
            pageTarget: self,
            pageAction: #selector(pageButtonTapped(_:))
        )
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
    @objc private func previousBlockTapped() {
        guard currentPage > 1 else { return }
        currentPage = max(1, currentPage - maxPagesShown)
        applyPagination()
        scrollToTop()
    }
    @objc private func nextBlockTapped() {
        let totalPages = max(1, (totalResults + itemsPerPage - 1) / itemsPerPage)
        guard currentPage < totalPages else { return }
        currentPage = min(totalPages, currentPage + maxPagesShown)
        applyPagination()
        scrollToTop()
    }

    private func scrollToTop() {
        collectionView.layoutIfNeeded()
        collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.adjustedContentInset.top), animated: false)
    }

    private func configureUI() {
        view.addSubviews([collectionView, emptyLabel])
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.bottom.equalToSuperview()
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
        let cell = collectionView.dequeue(LikedCollectionViewCell.self, for: indexPath)
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

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let totalPages = max(1, (totalResults + itemsPerPage - 1) / itemsPerPage)
        guard totalPages > 1 else { return .zero }
        return CGSize(width: collectionView.frame.width, height: 64)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: UICollectionView.paginationFooter, for: indexPath
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

        return .deleteSwipe { [weak self] completion in
            guard let self else {
                completion(false)
                return
            }

            self.alertWithCancel(
                message: "마음 표현하기를 취소하시겠어요?",
                cancelTitle: "유지하기",
                confirmTitle: "취소하기",
                successMessage: "마음 표현하기를 취소했어요.",
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
    }

    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let actualIndex = (currentPage - 1) * itemsPerPage + indexPath.item
        guard actualIndex < allLikedBooks.count else { return nil }

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let cancelLike = UIAction(
                title: "마음 표현 취소",
                image: UIImage(named: "heart")?
                    .withRenderingMode(.alwaysTemplate)
                    .withTintColor(.customAlert, renderingMode: .alwaysOriginal),
                attributes: .destructive
            ) { _ in
                self?.confirmCancelLike(at: actualIndex)
            }
            return UIMenu(children: [cancelLike])
        }
    }

    private func confirmCancelLike(at index: Int) {
        guard index < allLikedBooks.count else { return }
        let book = allLikedBooks[index]

        alertWithCancel(
            message: "마음 표현하기를 취소하시겠어요?",
            cancelTitle: "유지하기",
            confirmTitle: "취소하기",
            successMessage: "마음 표현하기를 취소했어요.",
            okHandler: { [weak self] in
                guard let self else { return }
                CoreDataManager.shared.decrementLikeCount(for: book.isbn13Int)
                self.allLikedBooks.removeAll { $0.isbn13 == book.isbn13 }
                self.totalResults = self.allLikedBooks.count
                self.applyPagination()
                self.updateEmptyState()
            }
        )
    }
}
