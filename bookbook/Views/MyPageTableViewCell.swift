
import UIKit
import SnapKit

class MyPageTableViewCell: UITableViewCell {

    let menuName: UILabel = {
        let label = UILabel()
        label.textColor = .bk1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    let buttonImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.right")
        image.tintColor = .bk1
        image.contentMode = .scaleAspectFit
        return image
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    private func configureUI() {
        contentView.addSubviews([menuName, buttonImage])
        menuName.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }
        buttonImage.snp.makeConstraints { make in
            make.size.equalTo(17)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }
}
