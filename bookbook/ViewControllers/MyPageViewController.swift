
import UIKit
import SnapKit

class MyPageViewController: UIViewController {

    private let profileView = ProfileView()

    private let menuStackView: UIStackView = {
        let view = UIStackView()
        view.horizontalEqualStackView()
        return view
    }()

    private let profileButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private let myChoiceButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private let likeButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private let levelEventButton: UIButton = {
        let button = UIButton()
        return button
    }()

    private let tableView: UITableView = {
        let view = UITableView()
        view.register(MyPageTableViewCell.self, forCellReuseIdentifier: "MyPageTableViewCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "마이페이지"
        configureUI()
        profileView.delegate = self
        buttonActions()
    }

    private func buttonActions() {
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        myChoiceButton.addTarget(self, action: #selector(myChoiceButtonTapped), for: .touchUpInside)
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        levelEventButton.addTarget(self, action: #selector(levelEventButtonTapped), for: .touchUpInside)
    }
    @objc private func profileButtonTapped() {
        print(#function)
        let vc = EditProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func myChoiceButtonTapped() {
        print(#function)
//        let vc =
    }
    @objc private func likeButtonTapped() {
        print(#function)
        let vc = LikedViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    @objc private func levelEventButtonTapped() {
        print(#function)
        let vc = LevelEventViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func configureUI() {
        view.addSubviews([profileView, menuStackView, tableView])
        menuStackView.addArrangedSubviews([profileButton, myChoiceButton, likeButton, levelEventButton])
        profileView.snp.makeConstraints { make in
            <#code#>
        }
        menuStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(44)
            // add layout
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(menuStackView.snp.bottom).offset(<#T##amount: any ConstraintOffsetTarget##any ConstraintOffsetTarget#>)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension MyPageViewController: UITableViewDelegate, UITableViewDataSource, ProfileViewProtocol {
    func profileTapped() {
        let vc = LevelEventViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func nicknameTapped() {
        let vc = EditProfileViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPageTableViewCell", for: indexPath) as! MyPageTableViewCell
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
