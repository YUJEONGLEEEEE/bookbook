
import UIKit
import Kingfisher
import SnapKit

class SearchCollectionViewCell: UICollectionViewCell {

    let bookImage: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .bk5
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()

    let mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .leading
        view.spacing = 4
        return view
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 17, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .bk1
        return label
    }()

    let subLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .bk2
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = .bk3
        return label
    }()

    private let buttonStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 8
        view.alignment = .center
        view.distribution = .fill
        return view
    }()

    let showLiked: UIButton = {
        let button = UIButton()
        button.showLikedCounts(count: 0)
        return button
    }()

    // 사용자가 이미 북마크한 책일 때만 보이는 "담았어요" 표시(버튼 아님, 비탭).
    let bookmarked: UIButton = {
        let button = UIButton()
        button.showBookmarked()
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        bookImage.kf.cancelDownloadTask()
        bookImage.image = nil
        bookTitle.text = nil
        subLabel.text = nil
        descriptionLabel.text = nil
        bookmarked.isHidden = true
        showLiked.showLikedCounts(count: 0)
    }

    private func configureUI() {
        contentView.backgroundColor = .clear
        contentView.addSubviews([bookImage, mainStack])
        mainStack.addArrangedSubviews([bookTitle, subLabel, descriptionLabel, buttonStack])

        // ♥/담았어요 버튼은 콘텐츠에 딱 맞게 고정하고, 끝의 스페이서가 남는 가로 공간을 흡수한다.
        // (이렇게 안 하면 .fill 분배가 ♥ 박스를 옆으로 늘려 셀마다 크기가 달라짐)
        let buttonSpacer = UIView()
        buttonSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        buttonStack.addArrangedSubviews([showLiked, bookmarked, buttonSpacer])
        showLiked.setContentHuggingPriority(.required, for: .horizontal)
        showLiked.setContentCompressionResistancePriority(.required, for: .horizontal)
        bookmarked.setContentHuggingPriority(.required, for: .horizontal)
        bookmarked.setContentCompressionResistancePriority(.required, for: .horizontal)

        // self-sizing 리스트 셀: 추정 높이와 충돌하지 않도록 하단 제약은 priority 999
        bookImage.snp.makeConstraints { make in
            make.width.equalTo(87)
            make.height.equalTo(123)
            make.leading.top.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
        }
        mainStack.snp.makeConstraints { make in
            make.leading.equalTo(bookImage.snp.trailing).offset(16)
            make.top.trailing.equalToSuperview()
            make.bottom.equalToSuperview().priority(999)
        }
        mainStack.setCustomSpacing(8, after: descriptionLabel)
    }
}
