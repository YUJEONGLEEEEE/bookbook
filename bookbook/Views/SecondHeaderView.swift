//
//  SecondHeaderView.swift
//  bookbook
//
//  Created by 이유정 on 9/19/25.
//

import UIKit
import Alamofire
import Kingfisher
import SnapKit

class SecondHeaderView: UICollectionReusableView {

    weak var delegate: SecondHeaderProtocol?

    let secondSectionTitle: UILabel = {
        let label = UILabel()
        label.text = "사서들의추천도서목록"
        label.textAlignment = .left
        return label
    }()

    let libraryCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: "MainCollectionViewCell")
        return view
    }()

    let thirdSectionTitle: UILabel = {
        let label = UILabel()
        label.text = "최근출간책리스트"
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        libraryCollectionView.delegate = self
        libraryCollectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        self.addSubviews([secondSectionTitle, libraryCollectionView, thirdSectionTitle])
    }
}

extension SecondHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        delegate?.secondHeaderView(self, didSelectItemAt: indexPath)
    }
}
