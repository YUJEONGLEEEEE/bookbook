import UIKit
import SnapKit
import Lottie

final class EmptyTowerIntroView: UIView {
    private let dimView = UIView()
    private let lightView = LottieAnimationView(name: "light")
    private let bookImageView = UIImageView(image: UIImage(named: "book_non"))
    private let messageLabel = UILabel()

    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(dimView)
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        lightView.contentMode = .scaleAspectFit
        lightView.loopMode = .loop
        addSubview(lightView)

        bookImageView.contentMode = .scaleAspectFit
        addSubview(bookImageView)

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.minimumLineHeight = 24
        paragraph.maximumLineHeight = 24
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.attributedText = NSAttributedString(
            string: "마음에 남는 책 한 줄 작성하고\n다음 책을 얻어보세요!",
            attributes: [
                .font: UIFont.customFont(ofSize: 17, weight: .medium),
                .foregroundColor: UIColor.customWh,
                .paragraphStyle: paragraph
            ]
        )
        addSubview(messageLabel)

        bookImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(bookImageView.snp.width).multipliedBy(295.5 / 180.0)
        }
        lightView.snp.makeConstraints { make in
            make.center.equalTo(bookImageView)
            make.width.equalToSuperview()
            make.height.equalTo(lightView.snp.width)
        }
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().inset(24)
            make.bottom.equalTo(bookImageView.snp.top).offset(-60)
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    @objc private func handleTap() { onTap?() }

    func play() { lightView.play() }
}
