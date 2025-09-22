//
//  BookmarkViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit
import Alamofire
import SnapKit

class BookmarkViewController: UIViewController {

    var bookmarkedBooks: [BookData] = []

    let filterView = BookFilterView()
    let sortButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "line.3.horizontal"), for: .normal)
        button.tintColor = .black
        return button
    }()
    let tableView: UITableView = {
        let view = UITableView()
        view.register(BookmarkTableViewCell.self, forCellReuseIdentifier: "BookmarkTableViewCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Bookmark"
        tableView.delegate = self
        tableView.dataSource = self
        configureUI()
        sortButton.addTarget(self, action: #selector(sortButtonClicked), for: .touchUpInside)
    }

    @objc private func sortButtonClicked() {
        print(#function)
        // sort 로직
    }

    private func configureUI() {
        view.addSubviews([filterView, tableView])
        filterView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension BookmarkViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkTableViewCell", for: indexPath) as! BookmarkTableViewCell
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(#function)
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            bookmarkedBooks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

}
