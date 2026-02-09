
import UIKit
import SnapKit

class BestsellerCardView: UIView {

    private let blurBackgroundView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()

    private let logoLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .customMain
        label.text = " 읽담추천 "
        label.textColor = .customWh
        label.font = UIFont.customFont(ofSize: 13, weight: .medium)
        label.textAlignment = .center
        label.layer.cornerRadius = 24
        label.clipsToBounds = true
        return label
    }()

    private let bookCover: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()

    private let bookTitle: UILabel = {
        let label = UILabel()
        label.textColor = .bk1
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont.customFont(ofSize: 17, weight: .bold)
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .bk2
        label.font = UIFont.customFont(ofSize: 15, weight: .medium)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(coverImage: UIImage?, blurImage: UIImage?, title: String?, description: String?) {
        blurBackgroundView.image = blurImage
        bookCover.image = coverImage ?? UIImage(named: "icon_placeholder")
        bookTitle.text = title
        descriptionLabel.text = description ?? "베스트셀러 추천 도서입니다!"
    }

    func reset() {
        blurBackgroundView.image = nil
        bookCover.image = UIImage(named: "icon_placeholder")
        bookTitle.text = "베스트셀러"
        descriptionLabel.text = "추천 도서를 불러오는 중입니다..."
    }

    private func configureUI() {
        backgroundColor = .sub02
        layer.cornerRadius = 8
        clipsToBounds = true
        addSubviews([blurBackgroundView, bookTitle, descriptionLabel])
        blurBackgroundView.addSubviews([logoLabel, bookCover])
        blurBackgroundView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(280)
        }
        logoLabel.snp.makeConstraints { make in
            make.width.equalTo(77)
            make.height.equalTo(32)
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(12)
        }
        bookCover.snp.makeConstraints { make in
            make.height.equalTo(216)
            make.width.equalTo(150)
            make.center.equalToSuperview()
        }
        bookTitle.snp.makeConstraints { make in
            make.top.equalTo(blurBackgroundView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
        }
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(bookTitle.snp.bottom).offset(16)
            make.horizontalEdges.bottom.equalToSuperview().inset(24)
            make.height.lessThanOrEqualTo(59)

        }
    }
}
