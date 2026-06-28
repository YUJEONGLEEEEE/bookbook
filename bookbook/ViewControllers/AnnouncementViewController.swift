
import UIKit
import SnapKit

class AnnouncementViewController: UIViewController {

    private let faqData: [FAQ] = faqList

    private lazy var qnaExpandedStates = Array(repeating: false, count: faqData.count)

    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.register(NoticeHeaderView.self, forHeaderFooterViewReuseIdentifier: "NoticeHeaderView")
        view.register(NoticeATableViewCell.self, forCellReuseIdentifier: "NoticeATableViewCell")
        view.register(QnAHeaderView.self, forHeaderFooterViewReuseIdentifier: "QnAHeaderView")
        view.register(QnATableViewCell.self, forCellReuseIdentifier: "QnATableViewCell")
        view.separatorStyle = .singleLine
        view.separatorColor = .bk5
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.backgroundColor = .customWh
        view.sectionHeaderTopPadding = 0
        view.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "읽담이 궁금해"
        navigationItem.backButtonTitle = ""
        configureUI()
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func configureUI() {
        view.backgroundColor = .customWh
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
    }
}

extension AnnouncementViewController: NoticeHeaderViewProtocol, UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func headerViewButtonTapped(_ headerView: NoticeHeaderView) {
        let vc = NoticeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NoticeHeaderView") as! NoticeHeaderView
            header.delegate = self
            return header
        } else if section == 1 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "QnAHeaderView") as! QnAHeaderView
            return header
        }
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else if section == 1 {
            return faqData.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeATableViewCell", for: indexPath) as! NoticeATableViewCell
            if indexPath.row < noticeList.count {
                cell.titleLabel.text = noticeList[indexPath.row].title
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QnATableViewCell", for: indexPath) as! QnATableViewCell
            let isExpanded = qnaExpandedStates[indexPath.row]
            cell.toggleAnswerView(isExpanded: isExpanded)
            let item = faqData[indexPath.row]
            cell.titleLabel.text = item.question
            cell.answerLabel.text = item.answer
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let vc = NoticeViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 {
            qnaExpandedStates[indexPath.row].toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 52
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 52 : 60
    }
}
