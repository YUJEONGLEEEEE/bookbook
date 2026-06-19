
import UIKit
import SnapKit

class SignInViewController: UIViewController {

    private var phoneNumberDelegate: AccountValidationDelegate!
    private var isPhoneNumberValid = false
    private var isPhoneNumberFloating = false

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(ofSize: 36, weight: .bold)
        label.text = "휴대폰 번호로 \n로그인해주세요"
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    private let phoneNumberField: UITextField = {
        let field = UITextField()
        field.clearButtonMode = .whileEditing
        field.textColor = .white
        field.textAlignment = .left
        field.keyboardType = .phonePad
        field.clearButtonMode = .whileEditing
        field.tintColor = .customWh
        field.font = UIFont.customFont(ofSize: 17, weight: .medium)
        field.backgroundColor = .clear
        field.attributedPlaceholder = NSAttributedString(
            string: "휴대폰 번호를 입력해주세요",
            attributes: [
                .foregroundColor: UIColor.bk3,
                .font: UIFont.customFont(ofSize: 17, weight: .medium)
            ]
        )
        return field
    }()

    private let phoneNumberUnderline: UIView = {
        let view = UIView()
        view.whiteUnderline()
        return view
    }()

    private let phoneNumberFloatingPlaceholder: UILabel = {
        let label = UILabel()
        label.textColor = .bk3
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.text = "휴대폰 번호"
        label.alpha = 0
        return label
    }()

    private let phoneNumberStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = UIFont.customFont(ofSize: 14, weight: .regular)
        return label
    }()

    private let signInButton: UIButton = {
        let button = UIButton()
        button.confirmButton(title: "로그인하기", titleColor: .customWh, backColor: .bk4)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupWhiteBackButton()
        view.backgroundColor = .clear   // 공유 배경(AuthNavigationController) 비치도록
        setupKeyboardDismissMode()
        configureUI()
        addTargets()
        setupDelegates()
        setupPhonePadAccessoryToolbar()
        activateSigninButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupWhiteBackButton()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupDelegates() {
        phoneNumberDelegate = AccountValidationDelegate(statusLabel: phoneNumberStatusLabel, account: .phoneNumber)
        phoneNumberDelegate.validationResultHandler = { [weak self] isValid in
            self?.isPhoneNumberValid = isValid
            self?.activateSigninButton()
        }
        phoneNumberField.delegate = self
    }

    private func setupPhonePadAccessoryToolbar() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barStyle = .default

        let upButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: nil, action: nil)
        upButton.isEnabled = false
        let downButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: nil, action: nil)
        downButton.isEnabled = false
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonTapped))

        toolbar.items = [upButton, downButton, flexibleSpace, doneButton]
        phoneNumberField.inputAccessoryView = toolbar
    }
    @objc private func doneButtonTapped() {
        phoneNumberField.resignFirstResponder()
        guard isPhoneNumberValid else { return }
        signIn()
    }

    private func addTargets() {
        phoneNumberField.addTarget(self, action: #selector(beginEditingPhoneNumber), for: .editingDidBegin)
        phoneNumberField.addTarget(self, action: #selector(endEditingPhoneNumber), for: .editingDidEnd)
        signInButton.addTarget(self, action: #selector(signIn), for: .touchUpInside)
    }
    @objc private func beginEditingPhoneNumber() {
        print(#function)
        guard !isPhoneNumberFloating else { return }
        isPhoneNumberFloating = true
        phoneNumberField.attributedPlaceholder = nil

        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            self.phoneNumberFloatingPlaceholder.alpha = 1
            self.phoneNumberFloatingPlaceholder.transform = CGAffineTransform(translationX: 0, y: -34).scaledBy(x: 1, y: 1)
        }
    }
    @objc private func endEditingPhoneNumber() {
        print(#function)
        if phoneNumberField.text?.isEmpty ?? true {
            isPhoneNumberFloating = false
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
                self.phoneNumberFloatingPlaceholder.alpha = 0
                self.phoneNumberFloatingPlaceholder.transform = .identity
            }
            resetPhoneNumberPlaceholder()
            phoneNumberStatusLabel.text = nil
            isPhoneNumberValid = false
            activateSigninButton()
        }
    }
    @objc private func signIn() {
        print(#function)
        guard let phoneNumber = phoneNumberField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !phoneNumber.isEmpty,
              isPhoneNumberValid else { return }

        guard let account = CoreDataManager.shared.fetchAccount(by: phoneNumber) else {
            showAlert(message: "가입된 계정을 찾을 수 없습니다.\n회원가입을 먼저 진행해 주세요.")
            return
        }

        guard let accountUUID = account.id else {
            showAlert(message: "계정 정보가 올바르지 않습니다.")
            return
        }

        UserSession.currentAccountUUID = accountUUID
        UserSession.currentPhoneNumber = phoneNumber

        let nickname = account.nickname ?? "회원"

        if CoreDataManager.shared.isOnboardingCompleted {
            // 온보딩을 마친 기존 회원 → 랜덤 인사 + 곧장 메인 탭바로 진입
            let greetings = ["\(nickname)님 안녕하세요!", "\(nickname)님 좋은 하루예요!"]
            ToastManager.shared.pendingMessage = greetings.randomElement()
            MainTabBarController.setAsRoot()
        } else {
            // 온보딩 미완료 → 완료 전 저장된 선택값 초기화 후 취향 선택부터 다시
            CoreDataManager.shared.resetOnboardingSelections()
            ToastManager.shared.pendingMessage = "\(nickname)님 환영해요!"
            let preferenceVC = PreferenceCheckViewController()
            navigationController?.pushViewController(preferenceVC, animated: true)
        }
    }

    private func resetPhoneNumberPlaceholder() {
        phoneNumberField.attributedPlaceholder = NSAttributedString(
            string: "휴대폰 번호를 입력해주세요",
            attributes: [
                .foregroundColor: UIColor.bk3,
                .font: UIFont.customFont(ofSize: 17, weight: .medium)
            ]
        )
    }

    private func activateSigninButton() {
        if isPhoneNumberValid {
            signInButton.backgroundColor = .customMain
            signInButton.isEnabled = true
        } else {
            signInButton.backgroundColor = .bk4
            signInButton.isEnabled = false
        }
    }

    private func configureUI() {
        view.addSubviews([titleLabel, phoneNumberFloatingPlaceholder, phoneNumberField, phoneNumberUnderline, phoneNumberStatusLabel, signInButton])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(140)
        }
        phoneNumberFloatingPlaceholder.snp.makeConstraints { make in
            make.leading.equalTo(phoneNumberField.snp.leading)
            make.centerY.equalTo(phoneNumberField.snp.centerY)
        }
        phoneNumberField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32)
            make.height.equalTo(44)
            make.top.equalTo(titleLabel.snp.bottom).offset(240)
        }
        phoneNumberUnderline.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberField.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        phoneNumberStatusLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32)
            make.top.equalTo(phoneNumberUnderline.snp.bottom).offset(10)
        }
        signInButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        signIn()
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return phoneNumberDelegate.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
}
