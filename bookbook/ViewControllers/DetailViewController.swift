
import UIKit
import Alamofire
import CoreData
import Kingfisher
import SnapKit

final class DetailViewController: UIViewController {

    private let bookISBN: Int
    private var bookData: NaverBook?

    private var isLikedByUser: Bool = false
    private var isBookmarked: Bool = false

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let backgroundImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        return image
    }()

    private let overlayView = UIView()

    private let bookImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()

    private let firstStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .fill
        return view
    }()

    private let bookTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 20, weight: .bold)
        label.textColor = .bk1
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk2
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let subStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.distribution = .fill
        view.alignment = .center
        return view
    }()

    private let pubSpacer: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .horizontal)
        view.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return view
    }()

    private let publisherLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 16, weight: .medium)
        label.textColor = .bk2
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let subLabelSeparator: UILabel = {
        let label = UILabel()
        label.text = "|"
        label.textColor = .bk2
        label.textAlignment = .center
        label.font = UIFont.customFont(ofSize: 16, weight: .medium)
        return label
    }()

    private let pubDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 16, weight: .medium)
        label.textColor = .bk2
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let firstSeparator: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let secondStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.distribution = .fill
        view.alignment = .fill
        return view
    }()

    private let descriptionTitle: UILabel = {
        let label = UILabel()
        label.text = "책 소개"
        label.font = UIFont.customFont(ofSize: 16, weight: .bold)
        label.textColor = .bk1
        label.textAlignment = .left
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 16, weight: .regular)
        label.textColor = .bk2
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()

    private let thirdStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 16
        view.distribution = .fill
        view.alignment = .fill
        return view
    }()

    private let isbnTitle: UILabel = {
        let label = UILabel()
        label.text = "ISBN"
        label.textColor = .bk1
        label.font = UIFont.customFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        return label
    }()

    private let isbnLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bk2
        label.font = UIFont.customFont(ofSize: 16, weight: .regular)
        label.textAlignment = .left
        return label
    }()

    private let fixedView = UIView()

    private let secondSeparator: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let fourthStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.alignment = .center
        view.distribution = .fill
        return view
    }()

    private let likeStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.alignment = .center
        view.distribution = .fill
        return view
    }()

    private let likeButton: UIButton = {
        let button = UIButton()
        let image = UIImage(named: "heart")?.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: .normal)
        button.tintColor = .sub01
        button.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        return button
    }()

    private let likedCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.font = UIFont.customFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        label.textColor = .sub01
        return label
    }()

    private let bookmarkButton: UIButton = {
        let button = UIButton()
        button.setTitle("+ 내 책장에 담기", for: .normal)
        button.setTitleColor(.customMain, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.customFont(ofSize: 18, weight: .medium)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.customMain.cgColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        return button
    }()

    private let commentContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
        return view
    }()

    private let commentButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "comments_white")?.withRenderingMode(.alwaysTemplate)
        config.background.cornerRadius = 24
        config.background.backgroundColor = .customMain
        config.contentInsets = NSDirectionalEdgeInsets(
            top: 12, leading: 12, bottom: 12, trailing: 12
        )
        let button = UIButton(configuration: config)
        button.tintColor = .customWh
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowOpacity = 0.25
        button.layer.shadowRadius = 12
        button.snp.makeConstraints { make in
            make.size.equalTo(48)
        }
        return button
    }()

    init(isbn13: Int) {
        self.bookISBN = isbn13
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWh
        callRequest(isbn: bookISBN)
        configureUI()
        buttonActions()
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleBookStateChanged), name: .bookLikeDidChange, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleBookStateChanged), name: .bookBookmarkDidChange, object: nil
        )
    }

    @objc private func handleBookStateChanged() {
        updateButtonUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        setupWhiteBackButton()
        DispatchQueue.main.async {
            self.updateButtonUI()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }

    private func buttonActions() {
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        bookmarkButton.addTarget(self, action: #selector(didTapBookmarkButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
    }
    @objc private func didTapLikeButton() {
        let isAddingLike = !isLikedByUser

        if isLikedByUser {
            CoreDataManager.shared.decrementLikeCount(for: bookISBN)
        } else {
            CoreDataManager.shared.incrementLikeCount(for: bookISBN)
        }

        let newCount = CoreDataManager.shared.getLikedCount(for: bookISBN)
        let newLiked = CoreDataManager.shared.isLikedByUser(isbn13: bookISBN)
        updateLikeUI(likedCount: newCount, isLiked: newLiked)

        showToast(isAddingLike ? "마음을 표현했어요!" : "마음 표현하기를 취소했어요.")

        likeButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            usingSpringWithDamping: 0.6,

            initialSpringVelocity: 0.8,
            options: [],
            animations: {
                self.likeButton.transform = .identity
            })
    }
    @objc private func didTapBookmarkButton() {
        if isBookmarked {
            presentCustomAlert(
                message: "이 책을 내 책장에서 빼시겠어요?",
                actions: [
                    CustomAlertAction(title: "빼기", titleColor: .bk2, handler: { [weak self] in
                        guard let self else { return }
                        CoreDataManager.shared.toggleBookmark(isbn13: self.bookISBN, categoryId: 0)
                        self.updateBookmarkUI(isBookmarked: CoreDataManager.shared.isBookmarked(isbn13: self.bookISBN))
                        self.showAlert(message: "내 책장에 담기를 취소했어요.")
                    }),
                    CustomAlertAction(title: "유지하기", titleColor: .customBtn, handler: nil)
                ]
            )
        } else {
            CoreDataManager.shared.toggleBookmark(isbn13: bookISBN, categoryId: 0)
            updateBookmarkUI(isBookmarked: CoreDataManager.shared.isBookmarked(isbn13: bookISBN))
            showToast("내 책장에 넣었어요!")
        }
    }
    @objc private func didTapCommentButton() {
        commentButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: [],
            animations: {
                self.commentButton.transform = .identity
            }) { [weak self] _ in
                guard let self else { return }

                if let existing = self.fetchComment(for: Int64(self.bookISBN)) {
                    self.showAlert(message: "이미 작성된 책한줄이 있어요.") { [weak self] in
                        self?.presentCommentPopup(editing: existing)
                    }
                    return
                }
                self.presentCommentPopup(editing: nil)
            }
    }

    private func presentCommentPopup(editing comment: Comment?) {
        let popupVC = CommentPopUpViewController(
            isbn13: Int64(bookISBN),
            title: bookTitle.text ?? "",
            author: authorLabel.text ?? "",
            imageURL: bookData?.image
        )
        if let comment {
            popupVC.configureForEdit(comment: comment)
        }
        popupVC.onCommentUpdated = { [weak self] in
            guard let self else { return }
            self.navigationController?.pushViewController(MyCommentsViewController(), animated: true)
        }
        popupVC.modalPresentationStyle = .overFullScreen
        popupVC.modalTransitionStyle = .crossDissolve
        present(popupVC, animated: true)
    }

    private func fetchComment(for isbn13: Int64) -> Comment? {
        let request: NSFetchRequest<Comment> = Comment.fetchRequest()
        request.fetchLimit = 1
        if let account = CoreDataManager.shared.fetchCurrentAccount() {
            request.predicate = NSPredicate(format: "isbn13 == %lld AND account == %@", isbn13, account)
        } else {
            request.predicate = NSPredicate(format: "isbn13 == %lld", isbn13)
        }

        do {
            return try CoreDataManager.shared.context.fetch(request).first
        } catch {
            debugLog("comment fetch error: \(error)")
            return nil
        }
    }

    private func updateButtonUI() {
        let likedCount = CoreDataManager.shared.getLikedCount(for: bookISBN)
        let userLiked = CoreDataManager.shared.isLikedByUser(isbn13: bookISBN)
        let userBookmarked = CoreDataManager.shared.isBookmarked(isbn13: bookISBN)

        updateLikeUI(likedCount: likedCount, isLiked: userLiked)
        updateBookmarkUI(isBookmarked: userBookmarked)
    }

    private func updateLikeUI(likedCount: Int, isLiked: Bool) {
        self.isLikedByUser = isLiked
        likedCountLabel.text = "\(min(likedCount, 9999))"

        let imageName = isLiked ? "heart_colored" : "heart"
        likeButton.setImage(
            UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
    }

    private func updateBookmarkUI(isBookmarked: Bool) {
        self.isBookmarked = isBookmarked
        if isBookmarked {
            bookmarkButton.backgroundColor = .customMain
            bookmarkButton.setTitleColor(.customWh, for: .normal)
            bookmarkButton.setTitle("이미 책장에 담겼어요", for: .normal)
        } else {
            bookmarkButton.backgroundColor = .clear
            bookmarkButton.setTitleColor(.customMain, for: .normal)
            bookmarkButton.setTitle("+ 내 책장에 담기", for: .normal)
        }
    }

    private func loadBookImages(bookCoverUrl: String?) {
        let trimmed = bookCoverUrl?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !trimmed.isEmpty,
              !trimmed.lowercased().contains("noimg"),
              let coverUrl = URL(string: trimmed) else {
            bookImage.setBookCover(nil)
            backgroundImage.image = nil
            return
        }

        let blurOptions: KingfisherOptionsInfo = [
            .processor(BlurImageProcessor(blurRadius: 15)),
            .scaleFactor(UIScreen.main.scale)
        ]

        let sharpOptions: KingfisherOptionsInfo = [
            .scaleFactor(UIScreen.main.scale),
            .transition(.fade(0.3))
        ]

        backgroundImage.kf.setImage(
            with: coverUrl,
            options: blurOptions
        )

        bookImage.kf.setImage(
            with: coverUrl,
            placeholder: UIImage(named: "placeholder"),
            options: sharpOptions
        )
    }

    private func callRequest(isbn: Int) {
        LoadingManager.shared.showLoading(on: view)
        NetworkManager.shared.bookDetail(isbn: isbn) { [weak self] result in
            LoadingManager.shared.hideLoading()

            switch result {
            case .success(let bookInfo):
                guard let book = bookInfo.item.first else {
                    debugLog("네이버 검색 결과 없음")
                    DispatchQueue.main.async { self?.showNoBookInfoAlert() }
                    return
                }
                DispatchQueue.main.async {
                    self?.updateUI(with: book)
                }
            case .failure(let error):
                debugLog("네이버 API 에러: \(error)")
                DispatchQueue.main.async { self?.showNoBookInfoAlert() }
            }
        }
    }

    private func showNoBookInfoAlert() {
        setActionButtonsEnabled(false)
        guard presentedViewController == nil else { return }
        showAlert(message: "책 정보가 없습니다.\n잠시 후 시도해주세요.") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    private func setActionButtonsEnabled(_ enabled: Bool) {
        [likeButton, bookmarkButton, commentButton].forEach {
            $0.isEnabled = enabled
            $0.alpha = enabled ? 1.0 : 0.4
        }
    }

    private func updateUI(with book: NaverBook) {
        bookData = book
        bookTitle.text = book.title
        authorLabel.text = book.author.cleanAuthor()
        publisherLabel.text = book.publisher
        pubDateLabel.text = DateFormatter.yearFormatter.string(from: book.pubdate.toDate())
        isbnLabel.text = book.isbn.split(separator: " ").last.map(String.init) ?? book.isbn
        descriptionLabel.text = book.description
        descriptionLabel.setLineAndParagraphSpacing(lineSpacing: 6, paragraphSpacing: 12)
        loadBookImages(bookCoverUrl: book.image)
        updateButtonUI()

        RecentSearchStore.add(RecentBook(
            isbn13: String(bookISBN),
            title: book.title,
            author: book.author,
            publisher: book.publisher,
            cover: book.image,
            description: book.description
        ))
    }

    private func configureUI() {
        scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubviews([scrollView, fixedView, commentContainer])
        scrollView.addSubview(contentView)
        fixedView.addSubviews([secondSeparator, likeStack, bookmarkButton])
        commentContainer.addSubview(commentButton)
        contentView.addSubviews([backgroundImage, firstStack, firstSeparator, secondStack, thirdStack])
        backgroundImage.addSubview(overlayView)
        overlayView.addSubview(bookImage)
        firstStack.addArrangedSubviews([bookTitle, authorLabel, subStack])
        subStack.addArrangedSubviews([publisherLabel, subLabelSeparator, pubDateLabel, pubSpacer])
        secondStack.addArrangedSubviews([descriptionTitle, descriptionLabel])
        thirdStack.addArrangedSubviews([isbnTitle, isbnLabel])
        likeStack.addArrangedSubviews([likeButton, likedCountLabel])

        scrollView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        fixedView.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(92)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        commentContainer.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(secondSeparator.snp.top).offset(-16)
        }
        backgroundImage.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(430)
        }
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bookImage.snp.makeConstraints { make in
            make.width.equalTo(180)
            make.height.equalTo(256)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(32)
        }
        firstStack.snp.makeConstraints { make in
            make.top.equalTo(backgroundImage.snp.bottom).offset(32)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        firstStack.setCustomSpacing(16, after: bookTitle)
        firstStack.setCustomSpacing(24, after: authorLabel)
        firstSeparator.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(subStack.snp.bottom).offset(32)
        }
        secondStack.snp.makeConstraints { make in
            make.top.equalTo(firstSeparator.snp.bottom).offset(32)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        thirdStack.snp.makeConstraints { make in
            make.top.equalTo(secondStack.snp.bottom).offset(32)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(45)
        }
        secondSeparator.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        bookmarkButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(24)
            make.leading.equalTo(likeStack.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }
        likeStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.centerY.equalTo(bookmarkButton)
            make.width.equalTo(48)
        }
        likedCountLabel.snp.makeConstraints { make in
            make.width.equalTo(32)
        }
        commentButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension UILabel {
    func setLineAndParagraphSpacing(lineSpacing: CGFloat = 6.0, paragraphSpacing: CGFloat = 12.0) {

        guard let text = text else { return }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.paragraphSpacing = paragraphSpacing
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: text.count))
        self.attributedText = attributedString
    }
}
