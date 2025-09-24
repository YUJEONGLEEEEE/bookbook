//
//  UIView+Extension.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit
import SnapKit

extension UIView {

    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
        }
    }

    func addUnderline() {
        backgroundColor = .systemGray3
        snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
}

extension UIStackView {

    func addArrangedSubviews(_ views: [UIView]) {
        for view in views {
            self.addArrangedSubview(view)
        }
    }
}
