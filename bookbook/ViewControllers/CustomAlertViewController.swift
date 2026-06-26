import UIKit
import SnapKit

struct CustomAlertAction {
    let title: String
    let titleColor: UIColor
    let handler: (() -> Void)?

    init(title: String, titleColor: UIColor = .customBtn, handler: (() -> Void)? = nil) {
        self.title = title
        self.titleColor = titleColor
        self.handler = handler
    }
}

struct CustomAlertTextInput {
    let placeholder: String
    let validate: (String) -> Bool
}

final class CustomAlertViewController: UIViewController {

    private let alertTitle: String?
    private let message: String
    private let actions: [CustomAlertAction]
    private let input: CustomAlertTextInput?

    private weak var confirmButton: UIButton?

    init(title: String? = nil, message: String, actions: [CustomAlertAction], input: CustomAlertTextInput? = nil) {
        self.alertTitle = title
        self.message = message
        self.actions = actions.isEmpty ? [CustomAlertAction(title: "확인")] : actions
        self.input = input
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    deinit { NotificationCenter.default.removeObserver(self) }

    private lazy var inputField: UITextField = {
        let field = UITextField()
        field.font = .customFont(ofSize: 16, weight: .medium)
        field.textColor = .bk1
        field.textAlignment = .center
        field.borderStyle = .none
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.bk5.cgColor
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        field.attributedPlaceholder = NSAttributedString(
            string: input?.placeholder ?? "",
            attributes: [.foregroundColor: UIColor.bk3]
        )
        field.addAction(UIAction { [weak self] _ in
            guard let self, let input = self.input else { return }
            self.confirmButton?.isEnabled = input.validate(field.text ?? "")
        }, for: .editingChanged)
        return field
    }()

    private let dimView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return view
    }()

    private let card: UIView = {
        let view = UIView()
        view.backgroundColor = .customWh
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    private let textStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = .center
        view.spacing = 6
        return view
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .bk5
        return view
    }()

    private let buttonContainer = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        configureUI()
        if input != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(alertKeyboardWillShow(_:)),
                                                   name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(alertKeyboardWillHide(_:)),
                                                   name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if input != nil { inputField.becomeFirstResponder() }
    }

    @objc private func alertKeyboardWillShow(_ note: Notification) {
        guard let frame = (note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        UIView.animate(withDuration: 0.25) {
            self.card.transform = CGAffineTransform(translationX: 0, y: -frame.height * 0.45)
        }
    }

    @objc private func alertKeyboardWillHide(_ note: Notification) {
        UIView.animate(withDuration: 0.25) { self.card.transform = .identity }
    }

    private func configureUI() {
        view.addSubview(dimView)
        dimView.addSubview(card)
        card.addSubviews([textStack, separator, buttonContainer])

        if let alertTitle, !alertTitle.isEmpty {
            let titleLabel = UILabel()
            titleLabel.text = alertTitle
            titleLabel.font = .customFont(ofSize: 17, weight: .bold)
            titleLabel.textColor = .bk1
            titleLabel.textAlignment = .center
            titleLabel.numberOfLines = 0
            textStack.addArrangedSubview(titleLabel)
        }
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.font = .customFont(ofSize: 17, weight: .medium)
        messageLabel.textColor = .bk1
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        textStack.addArrangedSubview(messageLabel)

        if input != nil {
            textStack.setCustomSpacing(20, after: messageLabel)
            textStack.addArrangedSubview(inputField)
            inputField.snp.makeConstraints { make in
                make.width.equalTo(242)
                make.height.equalTo(44)
            }
        }

        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        card.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(338)
        }
        textStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.centerX.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        separator.snp.makeConstraints { make in
            make.top.equalTo(textStack.snp.bottom).offset(56)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        buttonContainer.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
        layoutButtons()
    }

    private func layoutButtons() {
        let confirm: UIButton
        if actions.count == 1 {
            let button = makeButton(actions[0])
            buttonContainer.addSubview(button)
            button.snp.makeConstraints { make in make.edges.equalToSuperview() }
            confirm = button
        } else {
            let left = makeButton(actions[0])
            let right = makeButton(actions[1])
            let vDivider = UIView()
            vDivider.backgroundColor = .bk5
            buttonContainer.addSubviews([left, vDivider, right])
            vDivider.snp.makeConstraints { make in
                make.centerX.verticalEdges.equalToSuperview()
                make.width.equalTo(1)
            }
            left.snp.makeConstraints { make in
                make.leading.verticalEdges.equalToSuperview()
                make.trailing.equalTo(vDivider.snp.leading)
            }
            right.snp.makeConstraints { make in
                make.trailing.verticalEdges.equalToSuperview()
                make.leading.equalTo(vDivider.snp.trailing)
            }
            confirm = right
        }
        if input != nil {
            confirm.isEnabled = false
            confirmButton = confirm
        }
    }

    private func makeButton(_ action: CustomAlertAction) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(action.title, for: .normal)
        button.setTitleColor(action.titleColor, for: .normal)
        button.setTitleColor(.bk4, for: .disabled)
        button.titleLabel?.font = .customFont(ofSize: 17, weight: .medium)
        button.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true) { action.handler?() }
        }, for: .touchUpInside)
        return button
    }
}
