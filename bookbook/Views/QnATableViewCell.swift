
import UIKit
import SnapKit

class QnATableViewCell: UITableViewCell {

    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bk1
        label.font = UIFont.customFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    let toggleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .bk2
        button.isUserInteractionEnabled = false   // 행 탭으로 토글
        return button
    }()

    let answerView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .sub02
        return view
    }()

    let answerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .bk1
        label.font = UIFont.customFont(ofSize: 15, weight: .medium)
        label.backgroundColor = .clear
        return label
    }()

    private let headerView = UIView()

    private lazy var mainStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [headerView, answerView])
        view.axis = .vertical
        view.spacing = 0
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        // 헤더(질문 + 화살표) — 접힌 상태에서도 항상 보인다.
        headerView.addSubviews([titleLabel, toggleButton])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().inset(20)
            make.trailing.lessThanOrEqualTo(toggleButton.snp.leading).offset(-16)
        }
        toggleButton.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.trailing.equalToSuperview().inset(20)
            make.centerY.equalTo(titleLabel)
        }

        answerView.addSubview(answerLabel)
        answerLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(24)
        }

        // 스택으로 묶어 접힘/펼침에 따라 셀 높이가 자동 변한다.
        contentView.addSubview(mainStack)
        mainStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func toggleAnswerView(isExpanded: Bool) {
        answerView.isHidden = !isExpanded
        let symbol = isExpanded ? "chevron.up" : "chevron.down"
        toggleButton.setImage(UIImage(systemName: symbol), for: .normal)
    }
}
