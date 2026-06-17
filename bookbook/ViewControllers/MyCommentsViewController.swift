
import UIKit
import CoreData
import SnapKit

class MyCommentsViewController: UIViewController {

    private var allComments: [Comment] = []
    private var pagedComments: [Comment] = []
    
    private var currentPage = 1
    private var totalResults = 0
    private let itemsPerPage = 20
    
    private var pageButtons: [UIButton] = []
    private let maxPagesShown = 10
    
    private let commentsTableView: UITableView = {
        let view = UITableView()
        view.register(MyCommentsTableViewCell.self, forCellReuseIdentifier: "MyCommentsTableViewCell")
        view.separatorStyle = .none
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 143
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 남겨진 책한줄이 없어요"
        label.font = UIFont.customFont(ofSize: 16, weight: .medium)
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
        navigationItem.title = "책한줄"
        navigationItem.backButtonTitle = ""
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        configureUI()
        setupButtonActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPage = 1
        loadComments()
    }
    
    private func loadComments() {
        LoadingManager.shared.showLoading(on: view)
        CoreDataManager.shared.fetchComments { [weak self] comments in
            DispatchQueue.main.async {
                guard let self else { return }
                LoadingManager.shared.hideLoading()
                
                self.allComments = self.uniqueByBook(comments)
                self.totalResults = self.allComments.count
                self.currentPage = 1
                self.applyPagination()
                self.showEmptyState()
            }
        }
    }
    
    private func applyPagination() {
        let startIndex = (currentPage - 1) * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, allComments.count)
        
        if startIndex < endIndex {
            pagedComments = Array(allComments[startIndex..<endIndex])
        } else {
            pagedComments = []
        }
        commentsTableView.reloadData()
        
        let totalPages = max(1, (totalResults + itemsPerPage - 1) / itemsPerPage)
        paginationStackView.isHidden = (totalResults == 0)
        setupPaginationButtons(totalPages: totalPages)
    }
    
    // 한 권당 하나의 코멘트만 유지
    private func uniqueByBook(_ comments: [Comment]) -> [Comment] {
        let sorted = comments.sorted {
            ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast)
        }
        var seenISBNs = Set<Int64>()
        var result: [Comment] = []
        for comment in sorted where !seenISBNs.contains(comment.isbn13) {
            seenISBNs.insert(comment.isbn13)
            result.append(comment)
        }
        return result
    }

    private func showEmptyState() {
        let isEmpty = allComments.isEmpty
        commentsTableView.isHidden = isEmpty
        emptyLabel.isHidden = !isEmpty
    }
    
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
            if self.commentsTableView.numberOfRows(inSection: 0) > 0 {
                self.commentsTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                                   at: .top,
                                                   animated: false)
            }
        }
    }
    
    private func configureUI() {
        view.addSubviews([commentsTableView, emptyLabel, paginationStackView])
        
        commentsTableView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(26)
            make.bottom.equalTo(paginationStackView.snp.top).offset(-32)
        }
        
        paginationStackView.snp.makeConstraints { make in
            make.height.equalTo(24)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func configureCell(_ cell: MyCommentsTableViewCell, with comment: Comment) {
        cell.rateLabel.text = String(format: "%.1f", comment.rating)

        let filledCount = Int((comment.rating + 0.01).rounded())
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        for (index, iv) in cell.rateView.enumerated() {
            if index < filledCount {
                iv.image = UIImage(systemName: "star.fill", withConfiguration: config)
                iv.tintColor = .customMain
            } else {
                iv.image = UIImage(systemName: "star", withConfiguration: config)
                iv.tintColor = .bk4
            }
        }
        
        cell.commentLabel.text = comment.comment

        if let date = comment.readDate {
            cell.dateLabel.text = DateFormatter.yyyyMMdd.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        // 책 제목
        cell.bookButton.setTitle("책 제목 불러오는 중…", for: .normal)
        
        let isbn = comment.isbn13
        guard isbn != 0 else { return }
        let isbnString = String(isbn)
        
        NetworkManager.shared.fetchBookmarkedBooks(isbns: [isbnString]) { [weak self, weak cell] books in
            DispatchQueue.main.async {
                guard let self,
                      let cell,
                      let indexPath = self.commentsTableView.indexPath(for: cell),
                      indexPath.row < self.pagedComments.count else { return }
                
                let title = books.first?.title ?? ""
                cell.bookButton.setTitle(title, for: .normal)
            }
        }
    }
    @objc private func bookButtonTapped(_ sender: UIButton) {
        let row = sender.tag
        guard row < pagedComments.count else { return }
        
        let comment = pagedComments[row]
        let isbnInt = Int(comment.isbn13)
        let detailVC = DetailViewController(isbn13: isbnInt)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension MyCommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pagedComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCommentsTableViewCell", for: indexPath) as! MyCommentsTableViewCell
        let comment = pagedComments[indexPath.row]
        configureCell(cell, with: comment)

        cell.bookButton.removeTarget(nil, action: nil, for: .touchUpInside)
        cell.bookButton.tag = indexPath.row
        cell.bookButton.addTarget(self,
                                  action: #selector(bookButtonTapped(_:)),
                                  for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let comment = pagedComments[indexPath.row]
        let isbn13 = comment.isbn13
        guard isbn13 != 0 else { return }
        
        let popupVC = CommentPopUpViewController(isbn13: isbn13)
        popupVC.configureForEdit(comment: comment)
        popupVC.onCommentUpdated = { [weak self] in
            self?.loadComments()   // 현재 목록 갱신 (새 화면 push 금지)
        }
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        present(popupVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard indexPath.row < pagedComments.count else { return nil }
        let comment = pagedComments[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            guard let self else {
                completion(false)
                return
            }
            
            self.alertWithCancel(
                message: "이 책한줄을 삭제할까요?",
                cancelTitle: "유지하기",
                confirmTitle: "삭제",
                successMessage: "책한줄을 삭제했어요.",
                okHandler: { [weak self] in
                    guard let self else { return }
                    
                    CoreDataManager.shared.deleteComment(comment)

                    self.allComments.removeAll { $0.objectID == comment.objectID }
                    self.totalResults = self.allComments.count

                    self.applyPagination()
                    self.showEmptyState()
                    
                    completion(true)
                }
            )
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
