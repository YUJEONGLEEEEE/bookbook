
import UIKit
import SnapKit

class SearchCollectionViewCell: UICollectionViewCell {

    var likedCount: Int = 0

    let bookImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()

    let mainStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        view.alignment = .leading
        return view
    }()

    let bookTitle: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .bk1
        return label
    }()

    let subLabel: UILabel = {
        let label = UILabel()
//        label.text = "\(author) · \(publisher)"
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .left
        label.numberOfLines = 1
        label.textColor = .bk2
        return label
    }()

    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
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
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "heart.fill")
        config.imagePadding = 4
        config.baseForegroundColor = .sub01
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
        let button = UIButton(configuration: config)
        button.isEnabled = false
        button.setTitleColor(.sub01, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 13)
        button.configuration?.imagePlacement = .leading
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.bk5.cgColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()

    let bookmarked: UIButton = {
        let button = UIButton()
        button.isEnabled = false
        button.isHidden = true
        button.setTitle(" 담았어요 ", for: .normal)
        button.setTitleColor(.sub02, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.sub02.cgColor
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        contentView.backgroundColor = .clear
        contentView.addSubviews([bookImage, mainStack])
        mainStack.addArrangedSubviews([bookTitle, subLabel, descriptionLabel, buttonStack])
        buttonStack.addArrangedSubviews([showLiked, bookmarked])

        bookImage.snp.makeConstraints { make in
            make.width.equalTo(86.74)
            make.height.equalTo(123)
            make.leading.equalToSuperview().offset(16)
        }
        mainStack.snp.makeConstraints { make in
            make.top.equalTo(bookImage.snp.top)
            make.leading.equalTo(bookImage.snp.trailing).offset(14)
            make.trailing.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview()
        }
        buttonStack.snp.makeConstraints { make in
            make.height.equalTo(32)
        }
    }
}

