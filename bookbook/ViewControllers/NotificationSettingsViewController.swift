import UIKit
import SnapKit

final class NotificationSettingsViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "독서 리마인더"
        label.font = .customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk1
        return label
    }()

    private let subLabel: UILabel = {
        let label = UILabel()
        label.text = "매일 설정한 시간에 책한줄 작성을 알려드려요"
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

    private let timePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko_KR")
        return picker
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWh
        navigationItem.title = "알림 설정"
        setupDefaultBackButton()
        loadCurrent()
        configureUI()
        reminderSwitch.addTarget(self, action: #selector(settingChanged), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(settingChanged), for: .valueChanged)
    }

    private func loadCurrent() {
        reminderSwitch.isOn = NotificationManager.isReminderOn
        var comps = DateComponents()
        comps.hour = NotificationManager.reminderHour
        comps.minute = NotificationManager.reminderMinute
        if let date = Calendar.current.date(from: comps) { timePicker.date = date }
        timePicker.isEnabled = reminderSwitch.isOn
        timePicker.alpha = reminderSwitch.isOn ? 1.0 : 0.4
    }

    @objc private func settingChanged() {
        timePicker.isEnabled = reminderSwitch.isOn
        timePicker.alpha = reminderSwitch.isOn ? 1.0 : 0.4
        let comps = Calendar.current.dateComponents([.hour, .minute], from: timePicker.date)
        NotificationManager.setReminder(enabled: reminderSwitch.isOn,
                                        hour: comps.hour ?? 20,
                                        minute: comps.minute ?? 0)
        if reminderSwitch.isOn { NotificationManager.requestAuthorization() }
    }

    private func configureUI() {
        view.addSubviews([titleLabel, reminderSwitch, subLabel, separator, timePicker])

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        reminderSwitch.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(24)
        }
        subLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().inset(24)
        }
        separator.snp.makeConstraints { make in
            make.top.equalTo(subLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        timePicker.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(8)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
    }
}
