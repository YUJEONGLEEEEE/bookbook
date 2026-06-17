
import UIKit
import SnapKit

class ProfileView: UIView {

    weak var delegate: ProfileViewProtocol?

    // 카드 배경 그라데이션: 흰 배경 위 customMain→sub01 세로 그라데이션을 30% 불투명도로 (파스텔)
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.customMain.withAlphaComponent(0.3).cgColor,
                        UIColor.sub01.withAlphaComponent(0.3).cgColor]
        layer.startPoint = CGPoint(x: 0.5, y: 0)
        layer.endPoint = CGPoint(x: 0.5, y: 1)
        return layer
    }()

    private let phraseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textColor = .bk2
        label.numberOfLines = 1
        return label
    }()

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 24, weight: .bold)
        label.textColor = .bk1
        label.numberOfLines = 1
        return label
    }()

    private let promiseLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 12, weight: .regular)
        label.textColor = .bk2
        label.numberOfLines = 1
        return label
    }()

    private let bookImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        addTap()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    private func addTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCard))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    @objc private func tapCard() {
        delegate?.profileTapped()
    }

    private func configureUI() {
        backgroundColor = .white
        layer.cornerRadius = 8
        clipsToBounds = true
        layer.insertSublayer(gradientLayer, at: 0)

        addSubviews([bookImage, phraseLabel, nicknameLabel, promiseLabel])

        bookImage.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(32)
            make.top.equalToSuperview().offset(16)
            make.width.equalTo(88)
            make.height.equalTo(130)
        }
        phraseLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(bookImage.snp.leading).offset(-12)
        }
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(phraseLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(bookImage.snp.leading).offset(-12)
        }
        promiseLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(bookImage.snp.leading).offset(-12)
        }
    }

    func configure(nickname: String, phrase: String, promise: String, bookImageName: String) {
        nicknameLabel.text = nickname
        phraseLabel.text = phrase
        promiseLabel.text = promise
        promiseLabel.isHidden = promise.isEmpty
        bookImage.image = UIImage(named: bookImageName)
    }
}
