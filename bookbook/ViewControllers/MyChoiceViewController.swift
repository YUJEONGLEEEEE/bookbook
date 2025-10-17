// checked preferences, gender, age

import UIKit
import SnapKit

class MyChoiceViewController: UIViewController {

    private let ageStack: UIStackView = {
        let view = UIStackView()
        view.userStackView()
        return view
    }()

    private let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "연령"
        label.textColor = .lightGray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    private let userAge: UILabel = {
        let label = UILabel()
        label.standardLabel()
        label.numberOfLines = 1
        return label
    }()

    private let ageUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let genderStack: UIStackView = {
        let view = UIStackView()
        view.userStackView()
        return view
    }()

    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.textColor = .lightGray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    private let userGender: UILabel = {
        let label = UILabel()
        label.standardLabel()
        label.numberOfLines = 1
        return label
    }()

    private let genderUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let genreStack: UIStackView = {
        let view = UIStackView()
        view.userStackView()
        return view
    }()

    private let genreLabel: UILabel = {
        let label = UILabel()
        label.text = "장르"
        label.textColor = .lightGray
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    private let userGenre: UILabel = {
        let label = UILabel()
        label.standardLabel()
        label.numberOfLines = 0
        return label
    }()

    private let genreUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "내 취향"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(editButtonTapped))
        navigationItem.rightBarButtonItem?.tintColor = .systemBlue
        configureUI()
    }

    @objc private func editButtonTapped() {
        print(#function, "취향_재설정")
        let vc = PreferenceCheckViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func configureUI() {
        view.addSubviews([ageStack, genderStack, genreStack])
        ageStack.addArrangedSubviews([ageLabel, userAge, ageUnderline])
        genderStack.addArrangedSubviews([genderLabel, userGender, genderUnderline])
        genreStack.addArrangedSubviews([genreLabel, userGenre, genreUnderline])
        ageStack.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(50)
        }
        genderStack.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(ageStack.snp.bottom).offset(30)
        }
        genreStack.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.top.equalTo(genderStack.snp.bottom).offset(30)
        }
    }
}
