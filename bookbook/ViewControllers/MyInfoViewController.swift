
import UIKit
import SnapKit

class MyInfoViewController: UIViewController {

    private var initialName = ""
    private var initialPromise = ""

    // MARK: - 이름(별명)
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "이름(별명)"
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textColor = .bk3
        return label
    }()

    private let nameField: UITextField = {
        let field = UITextField()
        field.font = UIFont.customFont(ofSize: 17, weight: .medium)
        field.textColor = .bk1
        field.autocorrectionType = .no
        field.clearButtonMode = .whileEditing
        return field
    }()

    private let nameUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let nameStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "2자 이상 8자 이하로 작성해주세요."
        label.font = UIFont.customFont(ofSize: 13, weight: .medium)
        label.textColor = .customAlert
        label.isHidden = true
        return label
    }()

    // MARK: - 다짐 한마디
    private let promiseLabel: UILabel = {
        let label = UILabel()
        label.text = "다짐 한마디"
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textColor = .bk3
        return label
    }()

    private let promiseField: UITextField = {
        let field = UITextField()
        field.font = UIFont.customFont(ofSize: 17, weight: .medium)
        field.textColor = .bk1
        field.autocorrectionType = .no
        field.clearButtonMode = .whileEditing
        field.attributedPlaceholder = NSAttributedString(
            string: "다짐하고 싶은 내용을 적어주세요",
            attributes: [.foregroundColor: UIColor.bk3]
        )
        return field
    }()

    private let promiseUnderline: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let promiseStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "20자 이내로 작성해주세요."
        label.font = UIFont.customFont(ofSize: 13, weight: .medium)
        label.textColor = .customAlert
        label.isHidden = true
        return label
    }()

    // MARK: - 하단
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.bk3, for: .normal)
        button.titleLabel?.font = UIFont.customFont(ofSize: 16, weight: .medium)
        return button
    }()

    private let withdrawButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원탈퇴", for: .normal)
        button.setTitleColor(.customAlert, for: .normal)
        button.titleLabel?.font = UIFont.customFont(ofSize: 16, weight: .medium)
        return button
    }()

    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.setTitleColor(.customBtn, for: .normal)
        button.titleLabel?.font = UIFont.customFont(ofSize: 16, weight: .medium)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWh
        navigationItem.title = "내 정보"
        setupKeyboardDismissMode()
        configureSaveButton()
        loadAccount()
        configureUI()
        addActions()
        updateSaveButtonState()
    }

    // MARK: - 데이터

    private func loadAccount() {
        let account = CoreDataManager.shared.fetchCurrentAccount()
        initialName = account?.nickname ?? ""
        initialPromise = account?.promise ?? ""
        nameField.text = initialName
        promiseField.text = initialPromise
    }

    private func configureSaveButton() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        let item = UIBarButtonItem(customView: saveButton)
        if #available(iOS 26.0, *) {
            item.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = item
    }

    private func addActions() {
        nameField.delegate = self
        promiseField.delegate = self
        nameField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        promiseField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        withdrawButton.addTarget(self, action: #selector(withdrawTapped), for: .touchUpInside)
    }

    @objc private func textChanged() {
        updateSaveButtonState()
    }

    // 저장 버튼 활성화 상태 갱신
    private func updateSaveButtonState() {
        let name = nameField.text ?? ""
        let promise = promiseField.text ?? ""
        let changed = (name != initialName) || (promise != initialPromise)
        // 이름은 바꾸지 않았으면(기존값 유지) 유효로 처리, 새로 바꿀 땐 가입과 동일 규칙(2~8자·숫자/특수문자 불가)
        let nameValid = (name == initialName) || (NicknameValidator.validate(name) == .valid)
        let valid = nameValid && promise.count <= 20
        saveButton.isEnabled = changed && valid
        saveButton.alpha = saveButton.isEnabled ? 1.0 : 0.4
    }

    // MARK: - Actions

    @objc private func saveTapped() {
        view.endEditing(true)   // 저장 누르는 순간 커서/키보드 내림
        alertWithCancel(message: "저장하시겠습니까?") { [weak self] in
            guard let self else { return }
            let name = self.nameField.text ?? ""
            let promise = self.promiseField.text ?? ""
            CoreDataManager.shared.updateProfile(nickname: name, promise: promise)
            self.initialName = name
            self.initialPromise = promise
            self.updateSaveButtonState()
            self.showToast("저장되었어요!")
        }
    }

    @objc private func logoutTapped() {
        alertWithCancel(message: "로그아웃하시겠습니까?") { [weak self] in
            // 세션만 정리 (계정 데이터 유지)
            UserSession.clear()
            self?.setRoot(AuthNavigationController(rootViewController: SignUpViewController()))
        }
    }

    @objc private func withdrawTapped() {
        presentCustomAlert(
            title: "정말 탈퇴하시겠어요?",
            message: "회원탈퇴시 계정은 삭제되며 복구되지 않습니다.",
            actions: [
                CustomAlertAction(title: "취소", titleColor: .bk1, handler: nil),
                CustomAlertAction(title: "탈퇴", titleColor: .customAlert, handler: { [weak self] in
                    self?.presentWithdrawTextConfirm()
                })
            ]
        )
    }

    // 2차 확인 — '탈퇴'를 직접 입력해야 최종 버튼이 활성화됨 (앱 커스텀 얼럿 사용)
    private func presentWithdrawTextConfirm() {
        presentCustomAlert(
            title: "회원탈퇴 확인",
            message: "탈퇴하려면 아래에 '탈퇴'를 입력해주세요.\n계정과 모든 데이터가 삭제되며\n복구할 수 없어요.",
            actions: [
                CustomAlertAction(title: "취소", titleColor: .bk1, handler: nil),
                CustomAlertAction(title: "탈퇴", titleColor: .customAlert, handler: { [weak self] in
                    self?.performWithdraw()
                })
            ],
            input: CustomAlertTextInput(placeholder: "탈퇴", validate: { $0 == "탈퇴" })
        )
    }

    private func performWithdraw() {
        // 현재 계정과 그 활동 데이터만 삭제 (다른 계정은 보존)
        CoreDataManager.shared.deleteCurrentAccount()
        UserSession.clear()
        // 기기에 계정이 하나도 안 남았을 때만 전역 UserDefaults 상태 초기화
        // (다른 계정이 남아있으면 그 계정 데이터라 보존)
        if CoreDataManager.shared.accountCount() == 0 {
            NotificationManager.resetAll()
            LevelRewardStore.clear()
            RecentSearchStore.clear()
            LevelEventViewController.clearProgress()
        }
        setRoot(AuthNavigationController(rootViewController: SignUpViewController()))
    }

    private func setRoot(_ vc: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        window.rootViewController = vc
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        window.makeKeyAndVisible()
    }

    // MARK: - Layout

    private func configureUI() {
        view.addSubviews([nameLabel, nameField, nameUnderline, nameStatusLabel,
                          promiseLabel, promiseField, promiseUnderline, promiseStatusLabel,
                          withdrawButton, logoutButton])

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        nameField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        nameUnderline.snp.makeConstraints { make in
            make.top.equalTo(nameField.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        nameStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(nameUnderline.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(24)
        }

        promiseLabel.snp.makeConstraints { make in
            make.top.equalTo(nameStatusLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(24)
        }
        promiseField.snp.makeConstraints { make in
            make.top.equalTo(promiseLabel.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        promiseUnderline.snp.makeConstraints { make in
            make.top.equalTo(promiseField.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        promiseStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(promiseUnderline.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(24)
        }

        withdrawButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        logoutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(withdrawButton.snp.top).offset(-20)
        }
    }
}

// MARK: - 입력창 안내 문구 표시/숨김
extension MyInfoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameField { nameStatusLabel.isHidden = false }
        if textField == promiseField { promiseStatusLabel.isHidden = false }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameField { nameStatusLabel.isHidden = true }
        if textField == promiseField { promiseStatusLabel.isHidden = true }
    }
}
