
import UIKit
import SnapKit

class BookFilterCollectionViewCell: UICollectionViewCell {

    let filterTitle: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textColor = .bk3
        return label
    }()

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureFilter()
        updateAppearance()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureFilter() {
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        contentView.addSubview(filterTitle)
        filterTitle.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(14)
        }
    }

    // 선택 시: 검정 알약 + 흰 글씨 / 미선택 시: 투명 배경 + 회색 글씨 (피그마)
    private func updateAppearance() {
        contentView.backgroundColor = isSelected ? .bk1 : .clear
        filterTitle.textColor = isSelected ? .customWh : .bk3
        filterTitle.font = UIFont.customFont(ofSize: 14, weight: isSelected ? .bold : .medium)
    }
}
