//
//  MyPageViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit
import SnapKit

class MyPageViewController: UIViewController {

    private let profileView = ProfileView()

    private let tableView: UITableView = {
        let view = UITableView()
        view.register(MyPageTableViewCell.self, forCellReuseIdentifier: "MyPageTableViewCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "MyPage"
        configureUI()
        profileView.delegate = self

    }

    private func configureUI() {
        view.addSubviews([profileView, tableView])
    }


}

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource, ProfileViewProtocol {

    func EditButtonTapped() {
        let editVC = EditProfileViewController()
        navigationController?.pushViewController(editVC, animated: true)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        <#code#>
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageTableViewCell", for: indexPath) as! MyPageTableViewCell
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        <#code#>
    }
}
