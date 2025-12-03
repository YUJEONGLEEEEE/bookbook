
import UIKit
import SnapKit

class FirstHeaderView: UICollectionReusableView {

    private let firstSectionTitle: UILabel = {
        let label = UILabel()
        label.text = "\(nickname)님, 이런 책은 어떠세요?"
        label.font = UIFont.customFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.textColor = .bk1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        addSubview(firstSectionTitle)
        firstSectionTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(56)
        }
    }
}
