
import UIKit
import SnapKit

final class SignUpViewController: UIViewController {

    private var nicknameDelegate: AccountValidationDelegate!
    private var phoneNumberDelegate: AccountValidationDelegate!
    private var isNicknameValid = false
    private var isPhoneNumberValid = false
    private var isNicknameFloating = false
    private var isPhoneNumberFloating = false
    private var isSubmitting = false


    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(ofSize: 36, weight: .bold)
        label.text = "책과 대화하는 앱\n읽담을 시작하세요"
        label.textColor = .white
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    private let nicknameField: UITextField = {
        let field = UITextField()
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .next
        field.textColor = .white
        field.textAlignment = .left
        field.keyboardType = .default
        field.tintColor = .customWh
        field.font = UIFont.customFont(ofSize: 17, weight: .medium)
        field.backgroundColor = .clear
        field.attributedPlaceholder = NSAttributedString(
            string: "사용할 이름을 만들어주세요",
            attributes: [
                .foregroundColor: UIColor.bk3,
                .font: UIFont.customFont(ofSize: 17, weight: .medium)
            ]
        )
        return field
    }()

    private let nicknameUnderline: UIView = {
        let view = UIView()
        view.whiteUnderline()
        return view
    }()

    private let nicknameFloatingPlaceholder: UILabel = {
        let label = UILabel()
        label.textColor = .bk3
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textAlignment = .left
        label.text = "이름"
        label.alpha = 0
        return label
    }()

    private let nicknameStatusLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 1
        label.font = UIFont.customFont(ofSize: 14, weight: .regular)
        return label
    }()

    private let phoneNumberField: UITextField = {
        let field = UITextField()
        field.clearButtonMode = .whileEditing
        field.returnKeyType = .done
        field.textColor = .white
        field.textAlignment = .left
        field.keyboardType = .phonePad
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
        button.setTitle("이미 가입하셨나요?", for: .normal)
        button.setTitleColor(.customWh, for: .normal)
        button.titleLabel?.font = UIFont.customFont(ofSize: 17, weight: .medium)
        button.titleLabel?.textAlignment = .center
        return button
    }()

    private let signupButton: UIButton = {
        let button = UIButton()
        button.confirmButton(title: "시작하기", titleColor: .customWh, backColor: .bk4)
        button.titleLabel?.font = .customFont(ofSize: 18, weight: .medium)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        configureUI()
        setupKeyboardDismissMode()
        addTargets()
        setupDelegates()
        setupPhonePadAccessoryToolbar()
        activateSignUpButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isSubmitting = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupDelegates() {
        nicknameDelegate = AccountValidationDelegate(statusLabel: nicknameStatusLabel, account: .nickname)
        nicknameDelegate.validationResultHandler = { [weak self] isValid in
            self?.isNicknameValid = isValid
            self?.activateSignUpButton()
        }
        phoneNumberDelegate = AccountValidationDelegate(statusLabel: phoneNumberStatusLabel, account: .phoneNumber)
        phoneNumberDelegate.validationResultHandler = { [weak self] isValid in
            self?.isPhoneNumberValid = isValid
            self?.activateSignUpButton()
        }

        nicknameField.delegate = self
        phoneNumberField.delegate = self
    }

    private func setupPhonePadAccessoryToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        toolbar.autoresizingMask = .flexibleWidth
        toolbar.barStyle = .default

        let upButton = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: self, action: #selector(upButtonTapped))
        let downButton = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: self, action: #selector(downButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(doneButtonTapped))

        toolbar.items = [upButton, downButton, flexibleSpace, doneButton]

        phoneNumberField.inputAccessoryView = toolbar
        phoneNumberField.addTarget(self, action: #selector(updateToolbarButtons), for: .editingDidBegin)
        nicknameField.addTarget(self, action: #selector(updateToolbarButtons), for: .editingDidBegin)

        updateToolbarButtons()
    }
    @objc private func upButtonTapped() {
        if phoneNumberField.isFirstResponder {
            nicknameField.becomeFirstResponder()
        }
    }
    @objc private func downButtonTapped() {
        if nicknameField.isFirstResponder {
            phoneNumberField.becomeFirstResponder()
        }
    }
    @objc private func doneButtonTapped() {
        phoneNumberField.resignFirstResponder()
        guard isNicknameValid, isPhoneNumberValid else { return }
        signUp()
    }
    @objc private func updateToolbarButtons() {
        guard let toolbar = (nicknameField.inputAccessoryView ?? phoneNumberField.inputAccessoryView) as? UIToolbar,
              let items = toolbar.items else { return }

        let upButton = items[0]
        let downButton = items[1]

        if nicknameField.isFirstResponder {
            upButton.isEnabled = false
            downButton.isEnabled = true
        } else if phoneNumberField.isFirstResponder {
            upButton.isEnabled = true
            downButton.isEnabled = false
        }
    }

    private func addTargets() {
        nicknameField.addTarget(self, action: #selector(beginEditingNickname), for: .editingDidBegin)
        nicknameField.addTarget(self, action: #selector(endEditingNickname), for: .editingDidEnd)
        phoneNumberField.addTarget(self, action: #selector(beginEditingPhoneNumber), for: .editingDidBegin)
        phoneNumberField.addTarget(self, action: #selector(endEditingPhoneNumber), for: .editingDidEnd)
        signInButton.addTarget(self, action: #selector(goToSignInPage), for: .touchUpInside)
        signupButton.addTarget(self, action: #selector(signUp), for: .touchUpInside)
    }
    @objc private func beginEditingNickname() {
        guard !isNicknameFloating else { return }
        isNicknameFloating = true
        nicknameField.attributedPlaceholder = nil
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            self.nicknameFloatingPlaceholder.alpha = 1
            self.nicknameFloatingPlaceholder.transform = CGAffineTransform(translationX: 0, y: -34).scaledBy(x: 1, y: 1)
        }
    }
    @objc private func endEditingNickname() {
        if nicknameField.text?.isEmpty ?? true {
            isNicknameFloating = false
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
                self.nicknameFloatingPlaceholder.alpha = 0
                self.nicknameFloatingPlaceholder.transform = .identity
            }
            resetNicknamePlaceholder()
            nicknameStatusLabel.text = nil
            isNicknameValid = false
            activateSignUpButton()
        }
    }
    @objc private func beginEditingPhoneNumber() {
        guard !isPhoneNumberFloating else { return }
        isPhoneNumberFloating = true
        phoneNumberField.attributedPlaceholder = nil
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut]) {
            self.phoneNumberFloatingPlaceholder.alpha = 1
            self.phoneNumberFloatingPlaceholder.transform = CGAffineTransform(translationX: 0, y: -34).scaledBy(x: 1, y: 1)
        }
    }
    @objc private func endEditingPhoneNumber() {
        if phoneNumberField.text?.isEmpty ?? true {
            isPhoneNumberFloating = false
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseInOut]) {
                self.phoneNumberFloatingPlaceholder.alpha = 0
                self.phoneNumberFloatingPlaceholder.transform = .identity
            }
            resetPhoneNumberPlaceholder()
            phoneNumberStatusLabel.text = nil
            isPhoneNumberValid = false
            activateSignUpButton()
        }
    }
    @objc private func goToSignInPage() {
        let signInVC = SignInViewController()
        navigationController?.pushViewController(signInVC, animated: true)
    }
    @objc private func signUp() {
        guard !isSubmitting else { return }
        guard let nickname = nicknameField.text,
              !nickname.isEmpty,
              let phoneNumber = phoneNumberField.text,
              !phoneNumber.isEmpty,
              isNicknameValid,
              isPhoneNumberValid else { return }

        if CoreDataManager.shared.fetchAccount(by: phoneNumber) != nil {
            showAlert(message: "해당 휴대폰 번호로 가입된 계정이 있습니다.\n로그인 화면으로 이동해 주세요.")
            return
        }

        let uuid = UUID()
        CoreDataManager.shared.saveAccount(uuid: uuid, nickname: nickname, phoneNumber: phoneNumber)
        UserSession.currentAccountUUID = uuid
        UserSession.currentPhoneNumber = phoneNumber

        ToastManager.shared.pendingMessage = "\(nickname)님 환영해요!"

        isSubmitting = true
        let preferVC = PreferenceCheckViewController()
        navigationController?.pushViewController(preferVC, animated: true)
    }

    private func resetNicknamePlaceholder() {
        nicknameField.attributedPlaceholder = NSAttributedString(
            string: "사용할 이름을 만들어주세요",
            attributes: [
                .foregroundColor: UIColor.bk3,
                .font: UIFont.customFont(ofSize: 17, weight: .medium)
            ]
        )
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

    private func activateSignUpButton() {

        if isNicknameValid && isPhoneNumberValid {
            signupButton.backgroundColor = .customMain
            signupButton.isEnabled = true
        } else {
            signupButton.backgroundColor = .bk4
            signupButton.isEnabled = false
        }
    }

    private func configureUI() {
        view.addSubviews([titleLabel, nicknameFloatingPlaceholder, nicknameField, nicknameUnderline, nicknameStatusLabel, phoneNumberFloatingPlaceholder, phoneNumberField, phoneNumberUnderline, phoneNumberStatusLabel, signInButton, signupButton])
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalToSuperview().offset(140)
        }
        nicknameFloatingPlaceholder.snp.makeConstraints { make in
            make.leading.equalTo(nicknameField.snp.leading)
            make.centerY.equalTo(nicknameField.snp.centerY)
        }
        nicknameField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32)
            make.height.equalTo(44)
            make.top.equalTo(titleLabel.snp.bottom).offset(159)
        }
        nicknameUnderline.snp.makeConstraints { make in
            make.top.equalTo(nicknameField.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        nicknameStatusLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32)
            make.top.equalTo(nicknameUnderline.snp.bottom).offset(4)
        }
        phoneNumberFloatingPlaceholder.snp.makeConstraints { make in
            make.leading.equalTo(phoneNumberField.snp.leading)
            make.centerY.equalTo(phoneNumberField.snp.centerY)
        }
        phoneNumberField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32)
            make.height.equalTo(44)
            make.top.equalTo(nicknameStatusLabel.snp.bottom).offset(32)
        }
        phoneNumberUnderline.snp.makeConstraints { make in
            make.top.equalTo(phoneNumberField.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        phoneNumberStatusLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(32)
            make.top.equalTo(phoneNumberUnderline.snp.bottom).offset(4)
        }
        signInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(signupButton.snp.top).offset(-20)
        }
        signupButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nicknameField {
            phoneNumberField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nicknameField {
            return nicknameDelegate.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        } else if textField == phoneNumberField {
            return phoneNumberDelegate.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
        return true
    }
}
