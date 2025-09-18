//
//  UIView+Extension.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit

extension UIView {

    func addSubviews(_ views: [UIView]) {
        for view in views {
            self.addSubview(view)
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
