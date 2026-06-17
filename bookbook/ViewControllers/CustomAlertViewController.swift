import UIKit
import SnapKit

// 커스텀 얼럿의 버튼 한 개 (제목 / 색 / 동작)
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

// iOS 기본 얼럿을 대체하는 커스텀 얼럿 (둥근 카드 + 가운데 메시지 + 하단 버튼 1~2개)
final class CustomAlertViewController: UIViewController {

    private let alertTitle: String?
    private let message: String
    private let actions: [CustomAlertAction]

    init(title: String? = nil, message: String, actions: [CustomAlertAction]) {
        self.alertTitle = title
        self.message = message
        self.actions = actions.isEmpty ? [CustomAlertAction(title: "확인")] : actions
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

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
        if actions.count == 1 {
            let button = makeButton(actions[0])
            buttonContainer.addSubview(button)
            button.snp.makeConstraints { make in make.edges.equalToSuperview() }
        } else {
            // 버튼 두 개: 좌/우 절반 + 세로 구분선
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
        }
    }

    private func makeButton(_ action: CustomAlertAction) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(action.title, for: .normal)
        button.setTitleColor(action.titleColor, for: .normal)
        button.titleLabel?.font = .customFont(ofSize: 17, weight: .medium)
        button.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true) { action.handler?() }
        }, for: .touchUpInside)
        return button
    }
}
