
import UIKit
import SnapKit

class MyCommentsTableViewCell: UITableViewCell {

     let rateStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 4
        view.distribution = .fill
        view.alignment = .center
        return view
    }()

     let rateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.textColor = .bk2
        label.numberOfLines = 1
        return label
    }()

     let starStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 0
        view.distribution = .fillEqually
        view.alignment = .fill
        return view
    }()

     let rateView: [UIImageView] = (0..<5).map { _ in
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
         let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        view.image = UIImage(systemName: "star", withConfiguration: config)
        view.tintColor = .bk4
        return view
    }

    let commentView: UIView = {
        let view = UIView()
        view.backgroundColor = .sub02
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    private let leftDoubleQuotes: UILabel = {
        let label = UILabel()
        label.text = "“"
        label.font = .customFont(ofSize: 30, weight: .medium)
        label.textColor = .bk1
        return label
    }()

    private let rightDoubleQuotes: UILabel = {
        let label = UILabel()
        label.text = "”"
        label.font = .customFont(ofSize: 30, weight: .medium)
        label.textColor = .bk1
        return label
    }()

    let commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk1
        label.textAlignment = .center
        label.numberOfLines = 0   // 한 줄 넘으면 생략(…) 대신 줄바꿈
        return label
    }()

    let bookButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.bk3, for: .normal)
        button.titleLabel?.font = UIFont.customFont(ofSize: 15, weight: .medium)
        button.titleLabel?.textAlignment = .left
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byTruncatingTail
        return button
    }()

    let bookUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    let dateStack: UIStackView = {
        let view = UIStackView()
        view.spacing = 8
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        return view
    }()

    let separateLine: UILabel = {
        let label = UILabel()
        label.text = "|"
        label.font = UIFont.customFont(ofSize: 15, weight: .medium)
        label.textColor = .bk3
        label.textAlignment = .center
        return label
    }()

    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bk3
        label.textAlignment = .right
        label.numberOfLines = 1
        label.font = UIFont.customFont(ofSize: 15, weight: .medium)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        rateLabel.text = nil
        commentLabel.text = nil
        bookButton.setTitle(nil, for: .normal)
        dateLabel.text = nil
    }

    private func configureUI() {
        contentView.addSubviews([rateStack, commentView, bookButton, dateStack])
        rateStack.addArrangedSubviews([rateLabel, starStack])
        starStack.addArrangedSubviews(rateView)
        commentView.addSubviews([leftDoubleQuotes, rightDoubleQuotes, commentLabel])
        bookButton.addSubview(bookUnderline)
        dateStack.addArrangedSubviews([separateLine, dateLabel])
        rateStack.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(8)
        }
        starStack.snp.makeConstraints { make in
            make.height.equalTo(16)
        }
        commentView.snp.makeConstraints { make in
            make.top.equalTo(rateStack.snp.bottom).offset(4)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(96)
        }
        leftDoubleQuotes.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
        commentLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().inset(40)
        }
        rightDoubleQuotes.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
        }
        let bottomSpacing: CGFloat = 32

        bookButton.snp.makeConstraints { make in
            make.top.equalTo(commentView.snp.bottom).offset(8)
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview().inset(bottomSpacing)
            make.trailing.lessThanOrEqualTo(dateStack.snp.leading).offset(-8)
        }
        bookUnderline.snp.makeConstraints { make in
            make.top.equalTo(bookButton.titleLabel?.snp.bottom ?? bookButton.snp.bottom).offset(1)
            make.horizontalEdges.equalTo(bookButton)
        }
        dateStack.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(bookButton)
        }

        // 날짜 우측 고정, 제목이 말줄임으로 양보
        dateStack.setContentHuggingPriority(.required, for: .horizontal)
        dateStack.setContentCompressionResistancePriority(.required, for: .horizontal)
        bookButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        bookButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
}
