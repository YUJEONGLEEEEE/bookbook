
import UIKit
import SnapKit

class MyPageViewController: UIViewController {

    // MARK: - 이벤트 카드 (레벨 달성)
    private let cardView = LevelEventCardView()

    // MARK: - 상단 4개 메뉴 버튼
    private lazy var infoButton   = makeMenuButton(icon: "menu_myinfo",      title: "내 정보")
    private lazy var choiceButton = makeMenuButton(icon: "menu_preferences", title: "내 취향")
    private lazy var likedButton  = makeMenuButton(icon: "menu_likes",       title: "마음서랍")
    private lazy var towerButton  = makeMenuButton(icon: "booktower",        title: "책탑쌓기")

    private let menuStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .center
        return view
    }()

    private let separator: UIView = {
        let view = UIView()
        view.addUnderline()
        return view
    }()

    // MARK: - 하단 메뉴 테이블
    private let menuTitles = ["최근 본 책", "공지사항", "자주 묻는 질문", "1:1 문의", "이용약관", "앱 버전"]

    private let tableView: UITableView = {
        let view = UITableView()
        view.register(MyPageTableViewCell.self, forCellReuseIdentifier: "MyPageTableViewCell")
        view.separatorStyle = .none
        view.rowHeight = 56
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        return view
    }()

    private lazy var notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "icon_notice")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        return button
    }()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWh
        customNavigationTitle()
        cardView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        configureUI()
        buttonActions()
        NotificationCenter.default.addObserver(
            self, selector: #selector(updateNotificationBadge), name: .appNotificationsDidChange, object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureProfile()
        updateNotificationBadge()
    }

    // MARK: - UI

    private func customNavigationTitle() {
        let title = UILabel()
        title.text = "내공간"
        title.font = UIFont.customFont(ofSize: 24, weight: .bold)
        title.textColor = .bk1
        let item = UIBarButtonItem(customView: title)
        if #available(iOS 26.0, *) {
            item.hidesSharedBackground = true
        }
        navigationItem.leftBarButtonItem = item

        notificationButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        let bellItem = UIBarButtonItem(customView: notificationButton)
        if #available(iOS 26.0, *) {
            bellItem.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = bellItem
    }

    @objc private func updateNotificationBadge() {
        let name = NotificationStore.unreadCount > 0 ? "icon_notice_active" : "icon_notice"
        notificationButton.setImage(UIImage(named: name)?.withRenderingMode(.alwaysOriginal), for: .normal)
    }

    @objc private func notificationButtonTapped() {
        push(NotificationListViewController())
    }

    private func makeMenuButton(icon: String, title: String) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: icon)
        config.imagePlacement = .top
        config.imagePadding = 10
        var t = AttributedString(title)
        t.font = UIFont.customFont(ofSize: 13, weight: .medium)
        config.attributedTitle = t
        config.baseForegroundColor = .bk1
        config.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0)
        return UIButton(configuration: config)
    }

    private func configureProfile() {
        let account = CoreDataManager.shared.fetchCurrentAccount()
        let nickname = account?.nickname ?? "독서왕"
        let promise = (account?.promise ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        CoreDataManager.shared.fetchComments { [weak self] comments in
            guard let self else { return }
            let earned = BookReward.earned(for: comments.count)

            var pool: [String] = []
            if let next = BookReward.next(after: comments.count) {
                if let latest = earned.last {
                    pool.append("목표 달성! \(latest.name)\(latest.name.objectParticle) 획득했어요.")
                    pool.append("\(next.name)\(next.name.objectParticle) 받기 위해 노력 중이에요!")
                } else {
                    pool.append("책한줄을 작성하고 첫 책 받아보세요!")
                }
            } else {
                pool.append("백과사전 획득 성공!")
            }
            if !promise.isEmpty {
                pool.append(promise)
            }
            let phrase = pool.randomElement() ?? pool.first ?? ""

            let bookImageName = earned.last?.imageName ?? ""
            self.cardView.configure(nickname: nickname, phrase: phrase, bookImageName: bookImageName)
        }
    }

    private func configureUI() {
        view.addSubviews([cardView, menuStackView, separator, tableView])
        menuStackView.addArrangedSubviews([infoButton, choiceButton, likedButton, towerButton])

        cardView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(106)
        }
        menuStackView.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(64)
        }
        separator.snp.makeConstraints { make in
            make.top.equalTo(menuStackView.snp.bottom).offset(32)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(separator.snp.bottom).offset(32)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    // MARK: - Actions

    private func buttonActions() {
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)
        choiceButton.addTarget(self, action: #selector(choiceTapped), for: .touchUpInside)
        likedButton.addTarget(self, action: #selector(likedTapped), for: .touchUpInside)
        towerButton.addTarget(self, action: #selector(towerTapped), for: .touchUpInside)
    }

    private func push(_ vc: UIViewController) {
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func infoTapped()   { push(MyInfoViewController()) }
    @objc private func choiceTapped()  { push(MyChoiceViewController()) }
    @objc private func likedTapped()   { push(LikedViewController()) }
    @objc private func towerTapped()   { push(LevelEventViewController()) }
}

// MARK: - TabReselectable
extension MyPageViewController: TabReselectable {
    func handleTabReselect() {
        tableView.setContentOffset(CGPoint(x: 0, y: -tableView.contentInset.top), animated: true)
        tableView.reloadData()
    }
}

// MARK: - ProfileViewProtocol
extension MyPageViewController: ProfileViewProtocol {
    func profileTapped() {
        push(LevelEventViewController())
    }

    func nicknameTapped() {
        push(MyInfoViewController())
    }
}

// MARK: - UITableView
extension MyPageViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageTableViewCell", for: indexPath) as! MyPageTableViewCell
        let title = menuTitles[indexPath.row]
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let trailing = (title == "앱 버전") ? appVersion : nil
        cell.configure(title: title, trailing: trailing)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: push(RecentSearchedViewController())
        case 1: push(AnnouncementViewController())
        case 2: push(AnnouncementViewController())
        case 3: push(QnAViewController())
        case 4: push(TermsViewController())
        case 5: push(AppVersionViewController())
        default: break
        }
    }
}
