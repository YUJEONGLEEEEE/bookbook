
import UIKit
import Alamofire
import SnapKit

class RecentSearchedViewController: UIViewController {

    private let tableView: UITableView = {
        let view = UITableView()
        view.register(RecentSearchedTableViewCell.self, forCellReuseIdentifier: "RecentSearchedTableViewCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        view.backgroundColor = .customWh
        view.addSubview(tableView)
    }
}

extension RecentSearchedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSearchedTableViewCell", for: indexPath) as! RecentSearchedTableViewCell
        return cell
    }
}
