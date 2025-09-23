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

    private var searchHistory: [String: Int] = [:]
    private var recentSearches: [String] = []
    private var popularSearches: [String] = []

    private var searchBooks: [BookData] = []

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

    private let recentSearchedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.register(RecentSearchedCollectionViewCell.self, forCellWithReuseIdentifier: "RecentSearchedCollectionViewCell")
        view.register(RecentSearchedHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "RecentSearchedHeaderView")
        return view
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
        NetworkManager.shared.searchBooks(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let bookInfo):
                    print("success")
                    self?.searchBooks = bookInfo.items
                    self?.resultCollectionView.reloadData()
                    self?.recentSearchedCollectionView.reloadData()
                    self?.startView.isHidden = true
                    self?.searchBar.resignFirstResponder()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    private func addSearchQuery(_ query: String) {
        // 빈도수 증가
        searchHistory[query, default: 0] += 1

        // 최근검색어 중복 제거 후 앞쪽으로 이동
        if let index = recentSearches.firstIndex(of: query) {
            recentSearches.remove(at: index)
        }
        recentSearches.insert(query, at: 0)

        // 최근검색어 갯수 20개로 제한
        if recentSearches.count > 20 {
            recentSearches.removeLast()
        }

        // 인기 검색어: 2회 이상 검색 -> 상위 10개 추출
        popularSearches = searchHistory
            .filter { $0.value > 1 }
            .sorted { $0.value > $1.value }
            .prefix(10)
            .map { $0.key }
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
        guard let query = searchBar.text, !query.isEmpty else { return }
        addSearchQuery(query)
        startSearch(query: query)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        print(#function)
        searchBar.resignFirstResponder()
    }
}

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView == recentSearchedCollectionView {
            return 2
        } else if collectionView == resultCollectionView {
            return 1
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == recentSearchedCollectionView {
            return section == 0 ? recentSearches.count : popularSearches.count
        } else if collectionView == resultCollectionView {
            return searchBooks.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == recentSearchedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentSearchedCollectionViewCell", for: indexPath) as! RecentSearchedCollectionViewCell
            let text = indexPath.section == 0 ? recentSearches[indexPath.item] : popularSearches[indexPath.item]
            cell.wordLabel.text = text
            return cell
        } else if collectionView == resultCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchCollectionViewCell", for: indexPath) as! SearchCollectionViewCell
            let list = searchBooks[indexPath.row]
            cell.bookTitle.text = list.title
            return cell
        }
        fatalError("Unknown CollectionView")
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if collectionView == recentSearchedCollectionView && kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "RecendSearchedHeaderView", for: indexPath) as! RecentSearchedHeaderView
            let titles = ["최근 검색어", "인기 검색어"]
            header.configure(title: titles[indexPath.section])
            return header
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if collectionView == recentSearchedCollectionView {
            return CGSize(width: collectionView.frame.width, height: 44)
        }
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == recentSearchedCollectionView {
            let text: String
            if indexPath.section == 0 {
                text = recentSearches[indexPath.item]
            } else {
                text = popularSearches[indexPath.item]
            }
            let font = UIFont.systemFont(ofSize: 14)
            let padding: CGFloat = 3
            let textAttributes = [NSAttributedString.Key.font: font]
            let textSize = (text as NSString).size(withAttributes: textAttributes)
            let height: CGFloat = 22
            return CGSize(width: textSize.width + padding, height: height)
        } else if collectionView == resultCollectionView {
            // resultCollectionViewCell 크기 지정
        }
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        if collectionView == recentSearchedCollectionView {
        } else if collectionView == resultCollectionView {
            let detailVC = DetailViewController()
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
