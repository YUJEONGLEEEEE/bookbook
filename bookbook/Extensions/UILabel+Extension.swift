
import UIKit

extension UILabel {

    func introTitleLabel(title: String) {
        text = title
        font = .customFont(ofSize: 28, weight: .bold)
        textColor = .black
        textAlignment = .left
    }

    static func emptyStateLabel(text: String, size: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .customFont(ofSize: size, weight: .medium)
        label.textColor = .bk3
        label.textAlignment = .center
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }
}
