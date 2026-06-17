
import UIKit
import SnapKit

extension UIView {

    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }

    func addUnderline() {
        backgroundColor = .bk5
        snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }

    func addBoldLine() {
        backgroundColor = .bk2
        snp.makeConstraints { make in
            make.height.equalTo(2)
        }
    }

    func addBolderLine() {
        backgroundColor = .bk6
        snp.makeConstraints { make in
            make.height.equalTo(8)
        }
    }

    func whiteUnderline() {
        backgroundColor = .white
        snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }

    func addVerticalLine() {
        backgroundColor = .lightGray
        snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(44)
        }
    }
}

extension UIStackView {

    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }

    func verticalEqualStackView() {
        axis = .vertical
        distribution = .fillEqually
        spacing = 10
        alignment = .center
    }

    func horizontalEqualStackView() {
        axis = .horizontal
        distribution = .fill
        spacing = 10
        alignment = .center
    }

}
