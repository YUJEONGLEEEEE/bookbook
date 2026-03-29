
import UIKit
import SnapKit

extension UILabel {
    
    func introTitleLabel(title: String) {
        text = title
        font = .customFont(ofSize: 28, weight: .bold)
        textColor = .black
        textAlignment = .left
        snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(80)
        }
    }

    func standardLabel() {
        font = .systemFont(ofSize: 17)
        textColor = .black
        textAlignment = .left
    }

    func subLabel() {
        font = .systemFont(ofSize: 15)
        textColor = .black
        textAlignment = .left
    }
}
