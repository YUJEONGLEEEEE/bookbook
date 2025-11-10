
import UIKit
import SnapKit

class AnnouncementViewController: UIViewController {

    private var qnaExpandedStates = Array(repeating: false, count: 5)

    private let faqData: [FAQ] = faqList

    private let noticeTableView: UITableView = {
        let view = UITableView()
        view.register(NoticeHeaderView.self, forHeaderFooterViewReuseIdentifier: "NoticeHeaderView")
        view.register(NoticeATableViewCell.self, forCellReuseIdentifier: "NoticeATableViewCell")
        return view
    }()

    private let qnaTableView: UITableView = {
        let view = UITableView()
        view.register(QnAHeaderView.self, forHeaderFooterViewReuseIdentifier: "QnAHeaderView")
        view.register(QnATableViewCell.self, forCellReuseIdentifier: "QnATableViewCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "읽담이 궁금해"
        navigationItem.backButtonTitle = ""
        configureUI()
        noticeTableView.delegate = self
        noticeTableView.dataSource = self
    }

    private func configureUI() {
        view.backgroundColor = .customWh
        view.addSubviews([noticeTableView, qnaTableView])
    }
}

extension AnnouncementViewController: NoticeHeaderViewProtocol, UITableViewDelegate, UITableViewDataSource {

    func headerViewButtonTapped(_ headerView: NoticeHeaderView) {
        print(#function)
        let vc = NoticeViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == noticeTableView {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "NoticeHeaderView") as! NoticeHeaderView
            header.delegate = self
            return header
        } else if tableView == qnaTableView {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "QnAHeaderView") as! QnAHeaderView
            return header
        }
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == noticeTableView {
            return  3
        } else if tableView == qnaTableView {
            return 5
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == noticeTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeATableViewCell", for: indexPath) as! NoticeATableViewCell
            return cell
        } else if tableView == qnaTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QnATableViewCell", for: indexPath) as! QnATableViewCell
            let isExpanded = qnaExpandedStates[indexPath.row]
            cell.toggleAnswerView(isExpanded: isExpanded)
            let item = faqData[indexPath.row]
            cell.titleLabel.text = item.question
            cell.answerLabel.text = item.answer
            return cell
        }
        fatalError("Unknown TableView")
     }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == noticeTableView {
            print(#function)
            let vc = NoticeViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else if tableView == qnaTableView {
            print(#function)
            qnaExpandedStates[indexPath.row].toggle()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}
