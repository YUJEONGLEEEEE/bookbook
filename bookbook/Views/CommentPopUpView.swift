//
//  CommentPopUpView.swift
//  bookbook
//
//  Created by 이유정 on 10/9/25.
//

import UIKit
import SnapKit

class CommentPopUpView: UIView {

    private let bookImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()

    private let bookTitle: UILabel = {
        let label = UILabel()
        label.standardLabel()
        label.numberOfLines = 0
        return label
    }()

    private let bookAuthor: UILabel = {
        let label = UILabel()
        label.subLabel()
        label.numberOfLines = 0
        return label
    }()

    private let separateLine: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let whenLabel: UILabel = {
        let label = UILabel()
        label.text = "다 읽은 날"
        label.font = .boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        label.textColor =  .black
        return label
    }()

    private let dateButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.lightGray, for: .normal)
        button.configuration?.imagePlacement = .trailing
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .lightGray
    }()

    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        return picker
    }()

    private let howLabel: UILabel = {
        let label = UILabel()
        label.text = "몇 점을 주고 싶나요?"
        label.font = .boldSystemFont(ofSize: 17)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()

    private let starStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = 10
        view.distribution = .fillEqually
        return view
    }()

    private let stars: [UIButton] = (0..<5).map { _ in
        let button = UIButton()
        let image = UIImage(systemName: "star", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20))
        button.setImage(image, for: .normal)
        button.tintColor = .black
        return button
    }

    private let writeLabel: UILabel = {
        let label = UILabel()
        label.text = "한 줄로 남겨보는 나의 생각"
        return label
    }()

    private let textField: UITextField = {
        let field = UITextField()
        field.placeholder = "한 줄로 표현해 보세요. (20자 이내)"
        field.textAlignment = .left
        field.textColor = .black
        field.font = .systemFont(ofSize: 15)
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.layer.borderWidth = 1
        return field
    }()

    private let buttonLine: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let buttonStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 0
        view.distribution = .fill
        view.alignment = .fill
        return view
    }()

    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(.black, for: .normal)
        button.tintColor = .black
        return button
    }()

    private let verticalSeparateLine: UIView = {
        let view = UIView()
        view.addVerticalLine()
        return view
    }()

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(.black, for: .normal)
        button.isEnabled = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        configureUI()
        addTargetActions()
        textField.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addTargetActions() {
        textField.addTarget(self, action: #selector(addText(_:)), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    @objc func addText(_ sender: UITextField) {
        saveButton.isEnabled = !(sender.text?.isEmpty ?? true)
    }
    @objc func cancelButtonTapped() {
        print(#function)
    }
    @objc func saveButtonTapped() {
        print(#function)
    }

    private func configureUI() {
        layer.cornerRadius = 10
        clipsToBounds = true

        addSubviews([bookImage, bookTitle, bookAuthor, separateLine, whenLabel, dateButton, howLabel, starStackView, writeLabel, textField, buttonLine, buttonStackView])
        buttonStackView.addArrangedSubviews([cancelButton, verticalSeparateLine, saveButton])

        buttonLine.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(buttonLine.snp.top)
        }
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(44)
            make.horizontalEdges.bottom.equalToSuperview()
        }
        cancelButton.snp.makeConstraints { make in
            make.width.equalTo(saveButton)
        }
    }
}

extension CommentPopUpView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        guard let stringRange = Range(range, in: text) else { return false }
        let updatedText = text.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 20
    }
}
