//
//  LikedViewController.swift
//  bookbook
//
//  Created by 이유정 on 10/8/25.
//

import UIKit
import Alamofire
import Kingfisher
import SnapKit
import Toast

class LikedViewController: UIViewController {

    var likedBooks: [BookData] = []

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(LikedCollectionViewCell.self, forCellWithReuseIdentifier: "LikedCollectionViewCell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "좋아요"
        configureUI()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func configureUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension LikedViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LikedCollectionViewCell", for: indexPath) as! LikedCollectionViewCell
        let list = likedBooks[indexPath.item]
        return cell
    }
}
