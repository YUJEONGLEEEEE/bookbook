import UIKit
import SnapKit

class MyChoiceViewController: UIViewController {

    private let ageLabel: UILabel = {
        let label = UILabel()
        label.text = "연령"
        label.textColor = .bk3
        label.textAlignment = .left
        label.font = .customFont(ofSize: 14, weight: .medium)
        return label
    }()

    private let userAge: UILabel = {
        let label = UILabel()
        label.textColor = .bk1
        label.textAlignment = .left
        label.font = .customFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 1
        return label
    }()

    private let ageUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let genderLabel: UILabel = {
        let label = UILabel()
        label.text = "성별"
        label.textColor = .bk3
        label.textAlignment = .left
        label.font = .customFont(ofSize: 14, weight: .medium)
        return label
    }()

    private let userGender: UILabel = {
        let label = UILabel()
        label.textColor = .bk1
        label.textAlignment = .left
        label.font = .customFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 1
        return label
    }()

    private let genderUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let genreLabel: UILabel = {
        let label = UILabel()
        label.text = "장르"
        label.textColor = .bk3
        label.textAlignment = .left
        label.font = .customFont(ofSize: 14, weight: .medium)
        return label
    }()

    private let userGenre: UILabel = {
        let label = UILabel()
        label.textColor = .bk1
        label.textAlignment = .left
        label.font = .customFont(ofSize: 17, weight: .medium)
        label.numberOfLines = 1
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
        let editItem = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(editButtonTapped))
        editItem.tintColor = .customBtn
        // iOS 26: 바 버튼 글래스 배경 제거
        if #available(iOS 26.0, *) {
            editItem.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = editItem
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserChoices()
    }

    private func loadUserChoices() {
        userAge.text = CoreDataManager.shared.fetchAgeRange()?.title ?? ""
        userGender.text = CoreDataManager.shared.fetchGender()?.title ?? ""
        let genres = CoreDataManager.shared.fetchGenres()
        userGenre.text = genres.isEmpty ? "" : genres.joined(separator: ", ")
    }

    @objc private func editButtonTapped() {
        debugLog(#function, "취향_재설정")
        let vc = PreferenceCheckViewController()
        vc.isEditMode = true
        navigationController?.pushViewController(vc, animated: true)
    }

    private func configureUI() {
        view.backgroundColor = .white
        view.addSubviews([
            ageLabel, userAge, ageUnderline,
            genderLabel, userGender, genderUnderline,
            genreLabel, userGenre, genreUnderline
        ])

        let safe = view.safeAreaLayoutGuide
        let textInset = 32
        let lineInset = 24
        let labelToValue = 29
        let labelToUnderline = 57
        let groupPitch = 89

        ageLabel.snp.makeConstraints { make in
            make.leading.equalTo(safe).offset(textInset)
            make.top.equalTo(safe).offset(32)
        }
        userAge.snp.makeConstraints { make in
            make.leading.equalTo(safe).offset(textInset)
            make.top.equalTo(ageLabel.snp.top).offset(labelToValue)
        }
        ageUnderline.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safe).inset(lineInset)
            make.top.equalTo(ageLabel.snp.top).offset(labelToUnderline)
        }

        genderLabel.snp.makeConstraints { make in
            make.leading.equalTo(safe).offset(textInset)
            make.top.equalTo(ageLabel.snp.top).offset(groupPitch)
        }
        userGender.snp.makeConstraints { make in
            make.leading.equalTo(safe).offset(textInset)
            make.top.equalTo(genderLabel.snp.top).offset(labelToValue)
        }
        genderUnderline.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safe).inset(lineInset)
            make.top.equalTo(genderLabel.snp.top).offset(labelToUnderline)
        }

        genreLabel.snp.makeConstraints { make in
            make.leading.equalTo(safe).offset(textInset)
            make.top.equalTo(genderLabel.snp.top).offset(groupPitch)
        }
        userGenre.snp.makeConstraints { make in
            make.leading.equalTo(safe).offset(textInset)
            make.trailing.lessThanOrEqualTo(safe).offset(-lineInset)
            make.top.equalTo(genreLabel.snp.top).offset(labelToValue)
        }
        genreUnderline.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safe).inset(lineInset)
            make.top.equalTo(genreLabel.snp.top).offset(labelToUnderline)
        }
    }
}
