//
//  EditProfileViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/20/25.
//

import UIKit
import SnapKit

class EditProfileViewController: UIViewController {

    private let imageLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 이미지"
        return label
    }()

    // profileImage, imageButton 둘중하나
    // profileImage의 경우 이미지 편집 버튼 하나 더 생성 + 이미지 편집 뷰컨파일 추가
    // imageButton의 경우 이미지 누르면 캐릭터 선택하는 팝업창 튀어나오도록 설정
    private let profileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.layer.cornerRadius = image.frame.width / 2
        image.clipsToBounds = true
        return image
    }()
    private let imageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "person"), for: .normal)
        button.layer.cornerRadius = button.frame.width / 2
        button.clipsToBounds = true
        return button
    }()

    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        return label
    }()

    private let nicknameTextField: UITextField = {
        let field = UITextField()
        return field
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
    }

    private func configureUI() {

    }
}
