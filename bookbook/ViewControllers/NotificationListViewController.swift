import UIKit
import SnapKit

final class NotificationListViewController: UIViewController {

    private var items: [AppNotification] = []

    private let tableView: UITableView = {
        let view = UITableView()
        view.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        view.separatorStyle = .none
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 88
        view.backgroundColor = .customWh
        return view
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 도착한 알림이 없어요"
        label.font = .customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk3
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWh
        navigationItem.title = "알림"
        setupDefaultBackButton()
        configureSettingsButton()
        tableView.delegate = self
        tableView.dataSource = self
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
        NotificationStore.markAllRead()   // 화면을 봤으니 모두 읽음 (배지 제거)
    }

    private func reload() {
        items = NotificationStore.all()
        tableView.reloadData()
        emptyLabel.isHidden = !items.isEmpty
    }

    private func configureSettingsButton() {
        let gear = UIButton(type: .system)
        gear.setImage(UIImage(systemName: "gearshape"), for: .normal)
        gear.tintColor = .bk1
        gear.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        let item = UIBarButtonItem(customView: gear)
        if #available(iOS 26.0, *) { item.hidesSharedBackground = true }
        navigationItem.rightBarButtonItem = item
    }

    @objc private func openSettings() {
        navigationController?.pushViewController(NotificationSettingsViewController(), animated: true)
    }

    private func configureUI() {
        view.addSubviews([tableView, emptyLabel])
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension NotificationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        cell.configure(with: items[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = items[indexPath.row]
        switch item.kind {
        case .bookReward:
            navigationController?.pushViewController(LevelEventViewController(), animated: true)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = items[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, done in
            NotificationStore.remove(id: item.id)
            self?.reload()
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - Cell

private final class NotificationCell: UITableViewCell {
    private let unreadDot = UIView()
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let dateLabel = UILabel()

    private static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yyyy.MM.dd HH:mm"
        return f
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        unreadDot.backgroundColor = .sub01
        unreadDot.layer.cornerRadius = 3
        titleLabel.font = .customFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .bk1
        bodyLabel.font = .customFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = .bk2
        bodyLabel.numberOfLines = 0
        dateLabel.font = .customFont(ofSize: 12, weight: .regular)
        dateLabel.textColor = .bk3

        contentView.addSubviews([unreadDot, titleLabel, bodyLabel, dateLabel])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().inset(24)
        }
        unreadDot.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel.snp.leading).offset(-10)
            make.size.equalTo(6)
        }
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(24)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel)
            make.bottom.equalToSuperview().inset(16)
        }
    }

    func configure(with n: AppNotification) {
        titleLabel.text = n.title
        bodyLabel.text = n.body
        dateLabel.text = Self.formatter.string(from: n.date)
        unreadDot.isHidden = n.isRead
        contentView.backgroundColor = n.isRead ? .customWh : .sub02
    }
}
