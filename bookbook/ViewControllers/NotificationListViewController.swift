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
        view.contentInset.top = 36
        view.verticalScrollIndicatorInsets.top = 36
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
        NotificationStore.markAllRead()
    }

    private func reload() {
        items = NotificationStore.all()
        tableView.reloadData()
        emptyLabel.isHidden = !items.isEmpty
    }

    private func configureSettingsButton() {
        let gear = UIButton(type: .system)
        gear.setImage(UIImage(named: "icon_setting")?.withRenderingMode(.alwaysOriginal), for: .normal)
        gear.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        gear.imageView?.contentMode = .scaleAspectFit
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
        cell.configure(with: items[indexPath.row], isLast: indexPath.row == items.count - 1)
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
    private let titleLabel = UILabel()
    private let bodyLabel = UILabel()
    private let dateLabel = UILabel()
    private let divider = UIView()

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
        titleLabel.font = .customFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .bk1
        titleLabel.numberOfLines = 0
        bodyLabel.font = .customFont(ofSize: 17, weight: .medium)
        bodyLabel.textColor = .bk2
        bodyLabel.numberOfLines = 0
        dateLabel.font = .customFont(ofSize: 14, weight: .medium)
        dateLabel.textColor = .bk3
        divider.backgroundColor = .bk5

        contentView.addSubviews([titleLabel, bodyLabel, dateLabel, divider])
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        bodyLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(bodyLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(12)
        }
        divider.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    func configure(with n: AppNotification, isLast: Bool) {
        divider.isHidden = isLast
        titleLabel.text = n.title
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 23
        paragraph.maximumLineHeight = 23
        bodyLabel.attributedText = NSAttributedString(
            string: n.body,
            attributes: [
                .font: UIFont.customFont(ofSize: 17, weight: .medium),
                .foregroundColor: UIColor.bk2,
                .paragraphStyle: paragraph
            ]
        )
        dateLabel.text = Self.formatter.string(from: n.date)
        contentView.backgroundColor = .customWh
    }
}
