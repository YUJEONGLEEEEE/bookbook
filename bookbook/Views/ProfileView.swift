//
//  ProfileView.swift
//  bookbook
//
//  Created by 이유정 on 9/20/25.
//

import UIKit
import SnapKit

class ProfileView: UIView {

    weak var delegate: ProfileViewProtocol?

    private let profileImage: UIImageView = {
        let image = UIImageView()
        return image
    }()

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    private let editButton: UIButton = {
        let button = UIButton()
        button.setTitle("편집", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .black
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        configureUI()
        editButton.addTarget(self, action: #selector(editButtonClicked), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func editButtonClicked() {
        print(#function)
        delegate?.EditButtonTapped()
    }

    private func configureUI() {
        self.addSubviews([profileImage, nicknameLabel, statusLabel, editButton])
    }
}
