import UIKit
import SnapKit

final class NotificationSettingsViewController: UIViewController {

    private let maxTimes = 5

    private let weekdayOrder: [(title: String, weekday: Int)] = [
        ("월", 2), ("화", 3), ("수", 4), ("목", 5), ("금", 6), ("토", 7), ("일", 1)
    ]

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "독서 리마인더"
        label.font = .customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk1
        return label
    }()

    private let subLabel: UILabel = {
        let label = UILabel()
        label.text = "선택한 요일·시간마다 책한줄 작성을 알려드려요"
        label.font = .customFont(ofSize: 13, weight: .regular)
        label.textColor = .bk3
        label.numberOfLines = 0
        return label
    }()

    private let reminderSwitch: UISwitch = {
        let view = UISwitch()
        view.onTintColor = .customMain
        return view
    }()

    private let separator: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    private let dayTitleLabel = NotificationSettingsViewController.sectionLabel("반복 요일")
    private lazy var dayButtons: [UIButton] = weekdayOrder.map { makeDayButton($0.title, weekday: $0.weekday) }
    private lazy var dayStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: dayButtons)
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 6
        return stack
    }()

    private let countTitleLabel = NotificationSettingsViewController.sectionLabel("하루 알림 횟수")
    private let countValueLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(ofSize: 15, weight: .medium)
        label.textColor = .customMain
        return label
    }()
    private let countStepper: UIStepper = {
        let stepper = UIStepper()
        stepper.minimumValue = 1
        stepper.value = 1
        return stepper
    }()

    private lazy var timePickers: [UIDatePicker] = (0..<maxTimes).map { _ in makeTimePicker() }
    private lazy var timeRows: [UIStackView] = (0..<maxTimes).map { makeTimeRow(index: $0) }
    private lazy var timeRowsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: timeRows)
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWh
        navigationItem.title = "알림 설정"
        setupDefaultBackButton()
        countStepper.maximumValue = Double(maxTimes)
        configureUI()
        loadCurrent()
        reminderSwitch.addTarget(self, action: #selector(settingChanged), for: .valueChanged)
        countStepper.addTarget(self, action: #selector(countChanged), for: .valueChanged)
    }

    // MARK: - Factory

    private static func sectionLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .customFont(ofSize: 15, weight: .medium)
        label.textColor = .bk1
        return label
    }

    private func makeDayButton(_ title: String, weekday: Int) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .customFont(ofSize: 14, weight: .medium)
        button.tag = weekday
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(dayTapped(_:)), for: .touchUpInside)
        button.snp.makeConstraints { make in make.height.equalTo(36) }
        return button
    }

    private func makeTimePicker() -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ko_KR")
        picker.addTarget(self, action: #selector(settingChanged), for: .valueChanged)
        return picker
    }

    private func makeTimeRow(index: Int) -> UIStackView {
        let label = UILabel()
        label.text = "알림 \(index + 1)"
        label.font = .customFont(ofSize: 15, weight: .regular)
        label.textColor = .bk2
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let row = UIStackView(arrangedSubviews: [label, spacer, timePickers[index]])
        row.axis = .horizontal
        row.alignment = .center
        return row
    }

    // MARK: - State

    private func setDay(_ button: UIButton, selected: Bool) {
        button.isSelected = selected
        button.backgroundColor = selected ? .customMain : .bk6
        button.setTitleColor(selected ? .customWh : .bk3, for: .normal)
    }

    private func loadCurrent() {
        reminderSwitch.isOn = NotificationManager.isReminderOn

        let days = NotificationManager.reminderWeekdays
        for button in dayButtons { setDay(button, selected: days.contains(button.tag)) }

        let times = NotificationManager.reminderTimes
        let count = min(max(times.count, 1), maxTimes)
        countStepper.value = Double(count)
        for (i, picker) in timePickers.enumerated() {
            let minutes = i < times.count ? times[i] : 20 * 60
            var comps = DateComponents()
            comps.hour = minutes / 60
            comps.minute = minutes % 60
            if let date = Calendar.current.date(from: comps) { picker.date = date }
        }
        applyCount(count)
        updateEnabledState()
    }

    private func applyCount(_ count: Int) {
        countValueLabel.text = "\(count)번"
        for (i, row) in timeRows.enumerated() { row.isHidden = i >= count }
    }

    private func updateEnabledState() {
        let on = reminderSwitch.isOn
        dayStack.isUserInteractionEnabled = on
        countStepper.isEnabled = on
        timeRowsStack.isUserInteractionEnabled = on
        [dayTitleLabel, dayStack, countTitleLabel, countValueLabel,
         countStepper, timeRowsStack].forEach { $0.alpha = on ? 1.0 : 0.4 }
    }

    // MARK: - Actions

    @objc private func dayTapped(_ sender: UIButton) {
        setDay(sender, selected: !sender.isSelected)
        settingChanged()
    }

    @objc private func countChanged() {
        applyCount(Int(countStepper.value))
        settingChanged()
    }

    @objc private func settingChanged() {
        updateEnabledState()
        let count = Int(countStepper.value)
        let times: [Int] = timePickers.prefix(count).map { picker in
            let c = Calendar.current.dateComponents([.hour, .minute], from: picker.date)
            return (c.hour ?? 20) * 60 + (c.minute ?? 0)
        }
        let weekdays = Set(dayButtons.filter { $0.isSelected }.map { $0.tag })

        guard reminderSwitch.isOn else {
            NotificationManager.setReminder(enabled: false, times: times, weekdays: weekdays)
            return
        }
        NotificationManager.ensureAuthorization { [weak self] granted in
            guard let self else { return }
            if granted {
                NotificationManager.setReminder(enabled: true, times: times, weekdays: weekdays)
            } else {
                self.reminderSwitch.setOn(false, animated: true)
                self.updateEnabledState()
                NotificationManager.setReminder(enabled: false, times: times, weekdays: weekdays)
                self.presentPermissionAlert()
            }
        }
    }

    private func presentPermissionAlert() {
        let alert = UIAlertController(
            title: "알림 권한이 필요해요",
            message: "리마인더를 받으려면 설정에서 읽담 알림을 켜주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "설정 열기", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }

    // MARK: - Layout

    private func configureUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews([titleLabel, reminderSwitch, subLabel, separator,
                                 dayTitleLabel, dayStack,
                                 countTitleLabel, countValueLabel, countStepper, timeRowsStack])

        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        reminderSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(24)
        }
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        separator.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        dayTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        dayStack.snp.makeConstraints { make in
            make.top.equalTo(dayTitleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        countTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(dayStack.snp.bottom).offset(28)
            make.leading.equalToSuperview().offset(24)
        }
        countStepper.snp.makeConstraints { make in
            make.centerY.equalTo(countTitleLabel)
            make.trailing.equalToSuperview().inset(24)
        }
        countValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(countTitleLabel)
            make.trailing.equalTo(countStepper.snp.leading).offset(-12)
        }
        timeRowsStack.snp.makeConstraints { make in
            make.top.equalTo(countTitleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}
