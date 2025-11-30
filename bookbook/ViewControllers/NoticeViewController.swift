
import UIKit
import SnapKit

class NoticeViewController: UIViewController {


    private let noticeData: [Notice] = noticeList

    private var noticeExpandedStates = Array(repeating: false, count: noticeList.count)

    private let tableView: UITableView = {
        let view = UITableView()
        view.register(NoticeBTableViewCell.self, forCellReuseIdentifier: "NoticeBTableViewCell")
        view.separatorColor = .bk5
        view.separatorStyle = .singleLine
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "공지사항"
        tableView.delegate = self
        tableView.dataSource = self
        configureUI()
    }

    private func configureUI() {
        view.backgroundColor = .customWh
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension  NoticeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noticeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoticeBTableViewCell", for: indexPath) as! NoticeBTableViewCell
        let isExpanded = noticeExpandedStates[indexPath.row]
        cell.toggleDescriptionView(isExpanded: isExpanded)
        let item = noticeData[indexPath.row]
        cell.dateLabel.text = item.date
        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = item.description
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        noticeExpandedStates[indexPath.row].toggle()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
}
