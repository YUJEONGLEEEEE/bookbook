//
//  ViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit
import Alamofire
import Kingfisher
import SnapKit

class MainViewController: UIViewController {

    var preferredBooks: [BookData] = []
    var recentBooks: [BookData] = []

    private let naverCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: "MainCollectionViewCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "BookBook"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: #selector(searchButtonClicked))
        naverCollectionView.delegate = self
        naverCollectionView.dataSource = self
    }

    @objc private func searchButtonClicked() {
        print(#function)
        self.tabBarController?.selectedIndex = 1
    }

    private func configureUI() {
        view.addSubview(naverCollectionView)
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SecondHeaderProtocol {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return preferredBooks.count
        case 1:
            return recentBooks.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        switch indexPath.section {
        case 0:
            let pBooks = preferredBooks[indexPath.item]
            if let url = URL(string: pBooks.image) {
                cell.bookImage.kf.setImage(with: url)
            } else {
                cell.bookImage.image = UIImage(named: "placeholder")
            }
        case 1:
            let rBooks = recentBooks[indexPath.item]
            if let url = URL(string: rBooks.image) {
                cell.bookImage.kf.setImage(with: url)
            } else {
                cell.bookImage.image = UIImage(named: "placeholder")
            }
        default:
            break
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else  {
            return UICollectionReusableView()
        }
        switch indexPath.section {
        case 0:
            let firstHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "FirstHeaderView", for: indexPath) as! FirstHeaderView
            return firstHeader
        case 1:
            let secondHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SecondHeaderView", for: indexPath) as! SecondHeaderView
            return secondHeader
        default:
            return UICollectionReusableView()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func secondHeaderView(_ headerView: SecondHeaderView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:
            return CGSize(width: collectionView.bounds.width, height: <#T##CGFloat#>)
        case 1:
            return CGSize(width: collectionView.bounds.width, height: <#T##Double#>)
        default:
            return .zero
        }
    }
}

