
import UIKit
import SnapKit

class QnAFormViewController: UIViewController {

    // 등록 완료 시 작성된 문의를 1:1 문의 목록으로 전달
    var onSubmit: ((QnaItem) -> Void)?

    private let titleHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "제목"
        label.font = UIFont.customFont(ofSize: 16, weight: .bold)
        label.textColor = .bk1
        return label
    }()

    private let titleField: UITextField = {
        let field = UITextField()
        field.font = UIFont.customFont(ofSize: 16, weight: .medium)
        field.textColor = .bk1
        field.attributedPlaceholder = NSAttributedString(
            string: "제목을 입력해주세요.",
            attributes: [.foregroundColor: UIColor.bk3]
        )
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.bk6.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        return field
    }()

    private let contentHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "내용"
        label.font = UIFont.customFont(ofSize: 16, weight: .bold)
        label.textColor = .bk1
        return label
    }()

    private let contentTextView: UITextView = {
        let view = UITextView()
        view.font = UIFont.customFont(ofSize: 16, weight: .medium)
        view.textColor = .bk1
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.bk6.cgColor
        view.textContainerInset = UIEdgeInsets(top: 16, left: 12, bottom: 16, right: 12)
        view.backgroundColor = .clear
        return view
    }()

    private let contentPlaceholder: UILabel = {
        let label = UILabel()
        label.text = "내용을 입력해주세요."
        label.font = UIFont.customFont(ofSize: 16, weight: .medium)
        label.textColor = .bk3
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWh
        navigationItem.title = "문의하기"
        configureSubmitButton()
        contentTextView.delegate = self
        setupKeyboardDismissMode()
        configureUI()
    }

    private func configureSubmitButton() {
        let submitButton = UIButton(type: .system)
        submitButton.setTitle("등록", for: .normal)
        submitButton.setTitleColor(.customBtn, for: .normal)
        submitButton.titleLabel?.font = UIFont.customFont(ofSize: 16, weight: .medium)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        let item = UIBarButtonItem(customView: submitButton)
        if #available(iOS 26.0, *) {
            item.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = item
    }

    @objc private func submitTapped() {
        let title = titleField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let content = contentTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !title.isEmpty, !content.isEmpty else {
            showAlert(message: "제목과 내용을 모두 입력해주세요.")
            return
        }

        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let item = QnaItem(date: today, question: title, questionBody: content, answer: nil)
        onSubmit?(item)
        showAlert(message: "작성하신 문의가 등록되었어요.") { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    private func configureUI() {
        view.addSubviews([titleHeaderLabel, titleField, contentHeaderLabel, contentTextView])
        contentTextView.addSubview(contentPlaceholder)

        titleHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        titleField.snp.makeConstraints { make in
            make.top.equalTo(titleHeaderLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
        contentHeaderLabel.snp.makeConstraints { make in
            make.top.equalTo(titleField.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(24)
        }
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(contentHeaderLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(180)
        }
        // 플레이스홀더는 textContainerInset과 같은 위치에 둔다.
        contentPlaceholder.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
        }
    }
}

extension QnAFormViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        contentPlaceholder.isHidden = !textView.text.isEmpty
    }
}
