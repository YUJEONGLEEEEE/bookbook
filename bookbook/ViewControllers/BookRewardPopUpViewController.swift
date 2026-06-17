import UIKit
import SnapKit

// 책탑쌓기 보상 획득 팝업 (책 표지 + 안내 + 확인)
// 여러 개를 순차로 띄울 수 있도록 onConfirm 콜백으로 다음 팝업을 연결한다.
final class BookRewardPopUpViewController: UIViewController {

    private let reward: BookReward
    var onConfirm: (() -> Void)?

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

    private let goalLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(ofSize: 15, weight: .medium)
        label.textColor = .bk2
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk1
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let coverImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .bk5
        return view
    }()

    private let confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.setTitleColor(.customBtn, for: .normal)
        button.titleLabel?.font = .customFont(ofSize: 17, weight: .medium)
        return button
    }()

    init(reward: BookReward) {
        self.reward = reward
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        configureUI()
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        goalLabel.text = "책한줄 \(reward.count)번 작성 목표 달성"
        titleLabel.text = "‘\(reward.name)’\(reward.name.objectParticle) 획득했어요!"
        coverImage.image = UIImage(named: reward.imageName)
    }

    @objc private func confirmTapped() {
        // 닫힘이 끝난 뒤 onConfirm 호출 → 다음 팝업을 깔끔하게 present
        dismiss(animated: true) { [weak self] in
            self?.onConfirm?()
        }
    }

    private func configureUI() {
        view.addSubview(dimView)
        dimView.addSubview(card)
        card.addSubviews([goalLabel, titleLabel, coverImage, separator, confirmButton])

        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        card.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(338)
        }
        goalLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(56)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(goalLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        coverImage.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.width.equalTo(132)
            make.height.equalTo(219)
        }
        separator.snp.makeConstraints { make in
            make.top.equalTo(coverImage.snp.bottom).offset(47)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        confirmButton.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
            make.height.equalTo(52)
        }
    }
}
