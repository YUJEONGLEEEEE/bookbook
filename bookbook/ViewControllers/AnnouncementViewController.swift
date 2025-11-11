
import UIKit
import SnapKit

class AnnouncementViewController: UIViewController {

    private var qnaExpandedStates = Array(repeating: false, count: 5)

    private let faqData: [FAQ] = faqList

    private let tableView: UITableView = {
        let view = UITableView()
        view.register(NoticeHeaderView.self, forHeaderFooterViewReuseIdentifier: "NoticeHeaderView")
        view.register(NoticeATableViewCell.self, forCellReuseIdentifier: "NoticeATableViewCell")
        view.register(QnAHeaderView.self, forHeaderFooterViewReuseIdentifier: "QnAHeaderView")
        view.register(QnATableViewCell.self, forCellReuseIdentifier: "QnATableViewCell")
        view.separatorStyle = .singleLine
        view.separatorColor = .bk5
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension AnnouncementViewController: NoticeHeaderViewProtocol, UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func headerViewButtonTapped(_ headerView: NoticeHeaderView) {
        print(#function)
        let vc = NoticeViewController()
        navigationController?.pushViewController(vc, animated: true)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeTableViewCell", for: indexPath) as! NoticeATableViewCell
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
        fatalError("Invalid Section")
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            print(#function)
            let vc = NoticeViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else if indexPath.section == 1 {
            print(#function)
            qnaExpandedStates[indexPath.row].toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 52
        } else if indexPath.section == 1 {
            if qnaExpandedStates[indexPath.row] {
                return UITableView.automaticDimension
            } else {
                return 60
            }
        }
        return 0
    }
}
