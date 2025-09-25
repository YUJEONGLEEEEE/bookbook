//
//  UIViewController+Extension.swift
//  bookbook
//
//  Created by 이유정 on 9/26/25.
//

import UIKit

extension UIViewController {

    func setupKeyboardDismissMode() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
