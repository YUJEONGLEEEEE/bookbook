
import UIKit
import CoreData
import Kingfisher
import SnapKit

class CommentPopUpViewController: UIViewController {

    private var rating: Double = 0.0
    private var bookISBN: Int64 = 0
    private var bookTitleText: String = ""
    private var bookAuthorText: String = ""
    private var bookImageURL: String? = nil

    private var initialReadDate: Date?
    private var initialRating: Double?
    private var initialComment: String?
    private var isEditMode: Bool = false
    private var editingComment: Comment?
    private var isSaving = false   // 저장 중복(더블탭) 방지
    private var hasSelectedDate = false

    var onCommentUpdated: (() -> Void)?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(isbn13: Int64, title: String = "", author: String = "", imageURL: String? = nil) {
        self.bookISBN = isbn13
        self.bookTitleText = title
        self.bookAuthorText = author
        self.bookImageURL = imageURL
        super.init(nibName: nil, bundle: nil)
    }

    private let starWidth: CGFloat = 40   // Figma: 별 1개 40 (행 232 = 40×5 + 8×4)
    private let totalStars: CGFloat = 5

    private lazy var panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))

    private let popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .customWh
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 10
        return view
    }()

    private let bookStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 16
        view.distribution = .fill
        view.alignment = .leading
        return view
    }()

    private let bookImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.backgroundColor = .bk3
        return image
    }()

    private let titleAuthorStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .equalSpacing
        view.alignment = .leading
        return view
    }()

    private let bookTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 15, weight: .medium)
        label.textColor = .bk1
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    private let bookAuthor: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textColor = .bk3
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private let separateLine: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let whenLabel: UILabel = {
        let label = UILabel()
        label.text = "다 읽은 날"
        label.font = UIFont.customFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        label.textColor =  .bk1
        return label
    }()

    private let dateButton: UIButton = {
        let button = UIButton()
        button.setTitle("....,..,..", for: .normal)
        button.setTitleColor(.customBtn, for: .normal)
        button.titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .bold)
        button.titleLabel?.textAlignment = .right
        button.titleLabel?.numberOfLines = 1
        return button
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .inline
        picker.tintColor = .customMain
        picker.backgroundColor = .customWh
        picker.layer.cornerRadius = 12
        picker.isHidden = true
        return picker
    }()

    private let howLabel: UILabel = {
        let label = UILabel()
        label.text = "몇 점을 주고 싶나요?"
        label.font = UIFont.customFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        label.textColor = .bk1
        return label
    }()

    private let starStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.distribution = .fillEqually
        view.alignment = .center
        return view
    }()

    private let stars: [UIButton] = (0..<5).map { _ in
        let button = UIButton()
        button.backgroundColor = .clear
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.imageView?.contentMode = .scaleAspectFit
        button.snp.makeConstraints { make in
            make.size.equalTo(40)   // Figma: 별 40×40
        }
        return button
    }

    private let writeLabel: UILabel = {
        let label = UILabel()
        label.text = "한 줄로 남겨보기"
        label.font = UIFont.customFont(ofSize: 16, weight: .bold)
        label.textAlignment = .left
        label.textColor = .bk1
        return label
    }()

    private let textfieldView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.layer.borderColor = UIColor.bk6.cgColor
        view.layer.borderWidth = 1
        return view
    }()

    // 폭을 넘으면 가로로 이어지지 않고 줄바꿈되도록 UITextView 사용
    private let commentField: UITextView = {
        let view = UITextView()
        view.font = UIFont.customFont(ofSize: 16, weight: .regular)
        view.textColor = .bk1
        view.textAlignment = .left
        view.backgroundColor = .clear
        view.isScrollEnabled = false
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        return view
    }()

    // UITextView는 placeholder가 없어 라벨로 대체 (입력 시작 시 숨김)
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "한 줄로 표현해 보세요. (20자 이내)"
        label.font = UIFont.customFont(ofSize: 16, weight: .regular)
        label.textColor = .bk3
        label.numberOfLines = 0
        return label
    }()

    private let buttonLine: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 0
        view.distribution = .fill
        view.alignment = .fill
        return view
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.bk2, for: .normal)
        button.titleLabel?.textAlignment = .center
        return button
    }()

    private let verticalSeparateLine: UIView = {
        let view = UIView()
        view.addVerticalLine()
        view.backgroundColor = .bk5   // Figma: 버튼 구분선 bk5 (lightGray 덮어쓰기)
        return view
    }()

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .medium)
        button.setTitleColor(.customBtn, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 팝업 뒤 배경을 살짝 어둡게(뒤 화면과 구분되는 정도)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        setupKeyboardDismissMode()
        bookTitle.text = bookTitleText
        bookAuthor.text = bookAuthorText
        bookImage.setBookCover(bookImageURL, coverMode: .scaleAspectFit)
        configureUI()
        setupStars()
        addTargetActions()
        commentField.delegate = self
        setDefaultDateIfNeeded()
        updateSaveButtonState()

        applyInitialValueIfNeeded()
        loadBookInfoIfNeeded()
    }

    private func loadBookInfoIfNeeded() {
        guard bookTitleText.isEmpty || bookImageURL == nil else { return }
        guard bookISBN != 0 else { return }

        NetworkManager.shared.fetchBookmarkedBooks(isbns: [String(bookISBN)]) { [weak self] books in
            DispatchQueue.main.async {
                guard let self, let book = books.first else { return }
                self.bookTitle.text = book.title
                self.bookAuthor.text = book.author.cleanAuthor()
                self.bookImage.setBookCover(book.cover, coverMode: .scaleAspectFit)
            }
        }
    }

    private func setDefaultDateIfNeeded() {
        guard !isEditMode else { return }
        let today = Date()
        datePicker.date = today
        dateButton.setTitle(DateFormatter.yyyyMMdd.string(from: today), for: .normal)
        hasSelectedDate = true
    }

    private func applyInitialValueIfNeeded() {
        guard isEditMode else { return }

        if let date = initialReadDate {
            hasSelectedDate = true
            datePicker.date = date
            dateButton.setTitle(DateFormatter.yyyyMMdd.string(from: date), for: .normal)
        }
        if let initialRating {
            self.rating = initialRating
            updateStarAppearance()
        }
        if let initialComment {
            commentField.text = initialComment
        }
        placeholderLabel.isHidden = !(commentField.text ?? "").isEmpty
        updateSaveButtonState()
    }

    // MARK: - 기존 코멘트 편집 설정
    func configureForEdit(comment: Comment) {
        editingComment = comment
        initialReadDate = comment.readDate
        initialRating = comment.rating
        initialComment = comment.comment
        isEditMode = true
    }

    private func setupStars() {
        starStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, star) in stars.enumerated() {
            let starView = star
            starView.tag = index
            starStackView.addArrangedSubview(starView)

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(starTapped(_:)))
            starView.addGestureRecognizer(tapGesture)
            starView.isUserInteractionEnabled = true
        }
        starStackView.addGestureRecognizer(panGesture)
        updateStarAppearance()
    }
    @objc private func starTapped(_ gesture: UITapGestureRecognizer) {
        guard let star = gesture.view as? UIButton else { return }
        let starIndex = CGFloat(star.tag)
        let positionInStar = gesture.location(in: star).x / starWidth

        rating = starIndex + positionInStar
        rating = round(rating * 2) / 2

        updateStarAppearance()
        updateSaveButtonState()
    }
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let position = gesture.location(in: starStackView)

        switch gesture.state {
        case .began, .changed:
            var closestStarIndex: Int = 0
            var minDistance: CGFloat = .greatestFiniteMagnitude

            for (index, star) in stars.enumerated() {
                let starFrame = starStackView.convert(star.frame, from: star.superview)
                let distance = abs(position.x - starFrame.midX)

                if distance < minDistance {
                    minDistance = distance
                    closestStarIndex = index
                }
            }
            let selectedStar = stars[closestStarIndex]
            let starFrame = starStackView.convert(selectedStar.frame, from: selectedStar.superview)
            let relativeX = (position.x - starFrame.minX) / starWidth

            rating = CGFloat(closestStarIndex) + relativeX
            rating = round(rating * 2) / 2

            updateStarAppearance()
            updateSaveButtonState()

        case .ended, .cancelled:
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.updateStarAppearance()
                self.updateSaveButtonState()
            }
        default:
            break
        }
    }

    private func updateStarAppearance() {
        for (index, star) in stars.enumerated() {
            let starPosition = CGFloat(index)
            let fillLevel = rating - starPosition

            if fillLevel >= 1.0 {
                star.setImage(UIImage(named: "star")?.withRenderingMode(.alwaysOriginal), for: .normal)
            } else if fillLevel >= 0.5 {
                star.setImage(UIImage(named: "star.half")?.withRenderingMode(.alwaysOriginal), for: .normal)
            } else {
                star.setImage(UIImage(named: "star")?.withRenderingMode(.alwaysTemplate), for: .normal)
                star.tintColor = .bk4
            }
        }
    }

    private func addTargetActions() {
        dateButton.addTarget(self, action: #selector(dateButtonTapped), for: .touchUpInside)
        datePicker.addTarget(self, action: #selector(dateSelected), for: .valueChanged)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    @objc private func dateButtonTapped() {
        datePicker.isHidden.toggle()
        if !datePicker.isHidden {
            popupView.bringSubviewToFront(datePicker)
        }
    }
    @objc private func dateSelected() {
        hasSelectedDate = true
        dateButton.setTitle(DateFormatter.yyyyMMdd.string(from: datePicker.date), for: .normal)
        datePicker.isHidden = true
        updateSaveButtonState()
    }
    @objc func cancelButtonTapped() {
        dismiss(animated: true)
    }
    @objc func saveButtonTapped() {
        let text = commentField.text ?? ""

        guard isFormValid() else { return }
        // 빠른 더블탭으로 중복 저장(+보상 중복 집계)되는 것 방지
        guard !isSaving else { return }
        isSaving = true

        if let editingComment {
            let ok = CoreDataManager.shared.updateComment(
                editingComment,
                readDate: datePicker.date,
                rating: rating,
                text: text
            )
            guard ok else { isSaving = false; showAlert(message: "저장에 실패했어요. 잠시 후 다시 시도해주세요."); return }
            showSavedAlertThenDismiss(message: "책한줄이 수정되었어요.")
        } else {
            let ok = CoreDataManager.shared.saveComment(
                isbn13: bookISBN,
                readDate: datePicker.date,
                rating: rating,
                comment: text
            )
            guard ok else { isSaving = false; showAlert(message: "저장에 실패했어요. 잠시 후 다시 시도해주세요."); return }
            NotificationManager.checkBookRewardAfterComment()   // 새 책 획득 시 알림
            showSavedAlertThenDismiss(message: "작성한 책한줄이 저장되었어요.")
        }
    }

    private func showSavedAlertThenDismiss(message: String) {
        showAlert(message: message) { [weak self] in
            let callback = self?.onCommentUpdated
            self?.dismiss(animated: true) {
                callback?()
            }
        }
    }

    private func isFormValid() -> Bool {
        let text = commentField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return rating > 0 && hasSelectedDate && !text.isEmpty
    }

    private func hasChangesFromOriginal() -> Bool {
        guard isEditMode else { return true }
        let text = commentField.text ?? ""
        let ratingChanged = rating != (initialRating ?? -1)
        let textChanged = text != (initialComment ?? "")
        let dateChanged: Bool
        if let initialReadDate {
            dateChanged = !Calendar.current.isDate(datePicker.date, inSameDayAs: initialReadDate)
        } else {
            dateChanged = hasSelectedDate
        }
        return ratingChanged || textChanged || dateChanged
    }

    private func updateSaveButtonState() {
        let enabled = isFormValid() && hasChangesFromOriginal()
        saveButton.isEnabled = enabled
        saveButton.alpha = enabled ? 1.0 : 0.5
    }

    private func configureUI() {
        view.addSubview(popupView)
        popupView.addSubviews([bookStack, separateLine, whenLabel, dateButton, datePicker, howLabel, starStackView, writeLabel, textfieldView, buttonLine, buttonStackView])
        bookStack.addArrangedSubviews([bookImage, titleAuthorStack])
        titleAuthorStack.addArrangedSubviews([bookTitle, bookAuthor])
        textfieldView.addSubviews([commentField, placeholderLabel])
        buttonStackView.addArrangedSubviews([cancelButton, verticalSeparateLine, saveButton])

        popupView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(338)
            make.height.equalTo(548)
        }
        bookStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(40)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        bookImage.snp.makeConstraints { make in
            make.height.equalTo(79)
            make.width.equalTo(56)
        }
        separateLine.snp.makeConstraints { make in
            make.top.equalTo(bookStack.snp.bottom).offset(24)
            make.horizontalEdges.equalToSuperview()
        }
        whenLabel.snp.makeConstraints { make in
            make.top.equalTo(separateLine.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        dateButton.snp.makeConstraints { make in
            make.top.equalTo(separateLine.snp.bottom).offset(24)
            make.trailing.equalToSuperview().inset(24)
        }
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(dateButton.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        howLabel.snp.makeConstraints { make in
            make.top.equalTo(whenLabel.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(24)
        }
        starStackView.snp.makeConstraints { make in
            make.top.equalTo(howLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        writeLabel.snp.makeConstraints { make in
            make.top.equalTo(starStackView.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(24)
        }
        textfieldView.snp.makeConstraints { make in
            make.top.equalTo(writeLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(24)   // 폭 290 (338 - 24×2)
            make.height.equalTo(80)                              // Figma: 텍스트창 H80
        }
        commentField.snp.makeConstraints { make in
            // 80 높이 박스 안에서 세로 중앙이 아닌 상단에 텍스트 정렬 (넘치면 줄바꿈)
            make.top.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(16)
        }
        placeholderLabel.snp.makeConstraints { make in
            // 텍스트 시작 위치와 동일하게 (commentField textContainerInset=0 기준)
            make.top.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
        }
        buttonLine.snp.makeConstraints { make in
            // 버튼 바로 위 1pt bk5 선 (top 제약 제거해 height 1과 충돌 방지)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(buttonStackView.snp.top)
        }
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        cancelButton.snp.makeConstraints { make in
            make.size.equalTo(saveButton)
        }
    }
}

extension CommentPopUpViewController: UITextViewDelegate {
    // 20자 제한
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let current = textView.text ?? ""
        guard let r = Range(range, in: current) else { return false }
        return current.replacingCharacters(in: r, with: text).count <= 20
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        updateSaveButtonState()
    }
}
