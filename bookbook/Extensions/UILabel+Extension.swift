
import UIKit
import SnapKit

extension UILabel {
    
    func introTitleLabel(title: String) {
        text = title
        font = .customFont(ofSize: 28, weight: .bold)
        textColor = .black
        textAlignment = .left
    }
}
