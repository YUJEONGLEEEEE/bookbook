import UIKit
import SnapKit
import Lottie

// 책 미획득(0개) 상태에서 책탑 화면 위에 뜨는 인트로 오버레이.
// dim(0.5) + light(Lottie) + 물음표 책(book_non) + 안내 라벨. 아무 곳이나 탭하면 사라짐.
// 레이아웃 기준: Figma 마이_책탑쌓기_최초 (book 180×295.5 / light 402×402 / label 17 Medium·행간24·흰색)
final class EmptyTowerIntroView: UIView {
    private let dimView = UIView()
    private let lightView = LottieAnimationView(name: "light")   // EventLottie/light.json
    private let bookImageView = UIImageView(image: UIImage(named: "book_non"))
    private let messageLabel = UILabel()

    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        // dim
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(dimView)
        dimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // light(글로우) — 책 뒤에 깔림
        lightView.contentMode = .scaleAspectFit
        lightView.loopMode = .loop
        addSubview(lightView)

        // 물음표 책
        bookImageView.contentMode = .scaleAspectFit
        addSubview(bookImageView)

        // 안내 라벨
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

        // 책: 가로 중앙 · 화면 세로 중앙 · 180×295.5
        bookImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(180)
            make.height.equalTo(bookImageView.snp.width).multipliedBy(295.5 / 180.0)
        }
        // light: 책 중심에 정렬 · 전체폭 정사각형
        lightView.snp.makeConstraints { make in
            make.center.equalTo(bookImageView)
            make.width.equalToSuperview()
            make.height.equalTo(lightView.snp.width)
        }
        // 라벨: 가로 중앙 · 책(글로우) 위
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
