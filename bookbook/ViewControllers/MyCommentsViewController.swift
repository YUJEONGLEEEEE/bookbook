//
//  MyCommentsViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/27/25.
//

import UIKit
import SnapKit

class MyCommentsViewController: UIViewController {

    private let commentsTableView: UITableView = {
        let view = UITableView()
        view.register(MyCommentsTableViewCell.self, forCellReuseIdentifier: "MyCommentsTableViewCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        commentsTableView.delegate = self
        commentsTableView.dataSource = self
    }

    private func configureUI() {
        view.addSubview(commentsTableView)
        commentsTableView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension MyCommentsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    

}
