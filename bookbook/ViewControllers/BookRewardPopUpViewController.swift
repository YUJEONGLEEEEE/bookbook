import UIKit
import SnapKit
import Lottie

final class GradientView: UIView {
    override class var layerClass: AnyClass { CAGradientLayer.self }
    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }
}

final class BookRewardPopUpViewController: UIViewController {

    private let reward: BookReward
    var onConfirm: (() -> Void)?

    private lazy var confettiView: LottieAnimationView = {
        let view = LottieAnimationView(name: reward.isFinal ? "Confetti_final" : "Confetti_basic")
        view.contentMode = .scaleAspectFit
        view.loopMode = .playOnce
        view.isUserInteractionEnabled = false
        return view
    }()

    private let gradientView: GradientView = {
        let view = GradientView()
        view.gradientLayer.colors = [
            UIColor.customMain.withAlphaComponent(0.3).cgColor,
            UIColor.sub01.withAlphaComponent(0.3).cgColor
        ]
        view.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        view.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        view.isUserInteractionEnabled = false
        return view
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

        goalLabel.text = reward.isFinal ? "책한줄 최종 목표 달성" : "책한줄 \(reward.count)번 작성 목표 달성"
        titleLabel.text = "‘\(reward.name)’\(reward.name.objectParticle) 획득했어요!"
        coverImage.image = UIImage(named: reward.imageName)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        confettiView.play()
    }

    @objc private func confirmTapped() {
        dismiss(animated: true) { [weak self] in
            self?.onConfirm?()
        }
    }

    private func configureUI() {
        view.addSubview(dimView)
        dimView.addSubview(card)
        dimView.addSubview(confettiView)
        card.addSubviews([goalLabel, titleLabel, coverImage, separator, confirmButton])

        if reward.isFinal {
            card.insertSubview(gradientView, at: 0)
            gradientView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

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
        confettiView.snp.makeConstraints { make in
            make.center.equalTo(card)
            make.width.equalTo(reward.isFinal ? 828 : 346)
            make.height.equalTo(464)
        }
    }
}
