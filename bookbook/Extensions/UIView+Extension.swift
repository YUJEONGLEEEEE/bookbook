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
        backgroundColor = .lightGray
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

    func verticalStackView() {
        axis = .vertical
        distribution = .fill
        spacing = 10
        alignment = .center
    }

    func verticalEqualStackView() {
        axis = .vertical
        distribution = .fillEqually
        spacing = 10
        alignment = .center
    }

    func horizontalStackView() {
        axis = .horizontal
        distribution = .fill
        spacing = 10
        alignment = .center
    }

    func horizontalEqualStackView() {
        axis = .horizontal
        distribution = .fill
        spacing = 10
        alignment = .center
    }

    func bookStackView() {
        axis = .vertical
        distribution = .fill
        spacing = 7
        alignment = .leading
    }
}
