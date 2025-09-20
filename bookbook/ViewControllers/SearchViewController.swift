//
//  SearchViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit
import Alamofire
import Kingfisher
import SnapKit

class SearchViewController: UIViewController {

    var searchBooks: [BookData] = []

    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder = "Search"
        bar.searchTextField.textColor = .black
        bar.searchBarStyle = .minimal
        bar.searchTextField.layer.cornerRadius = bar.searchTextField.frame.height / 2
        bar.clipsToBounds = true
        bar.searchTextField.clipsToBounds = true
        return bar
    }()

    private let startView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let startLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 17)
        label.text = "Search for a book"
        return label
    }()

    private let resultCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.register(SearchCollectionViewCell.self, forCellWithReuseIdentifier: "SearchCollectionViewCell")
        return view
    }()

    private let sortButton: UIButton = {
        let button = UIButton()
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Search"
        searchBar.delegate = self
        keyboardDismiss()
        configureUI()
        resultCollectionView.delegate = self
        resultCollectionView.dataSource = self
    }

    private func keyboardDismiss() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func startSearch(query: String) {
        print(#function)
        NetworkManager.shared.searchBooks(query: query) { result in
            switch result {
            case .success(let bookInfo):
                print("success")
            case .failure(let error):
                print(error)
            }
        }
    }

    private func configureUI() {

        view.addSubviews([searchBar, startView])
        startView.addSubview(startLabel)

        searchBar.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.height.equalTo(44)
            make.top.equalTo(view.safeAreaLayoutGuide)
        }

        startView.snp.makeConstraints { make in
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(searchBar.snp.bottom)
        }

        startLabel.snp.makeConstraints { make in
            make.center.equalTo(startView)
        }
    }
}

extension SearchViewController: UISearchBarDelegate {

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        print(#function)
        startView.isHidden = true
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(#function)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(#function)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print(#function)
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as! SearchCollectionViewCell
        let list = searchBooks[indexPath.row]
        cell.bookTitle.text = list.title
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }

}
