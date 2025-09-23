//
//  BookFilterView.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit
import Alamofire
import SnapKit

class BookFilterView: UIView {

    weak var delegate: BookFilterProtocol?

    var filters: [BookFilter] = [] {
        didSet {
            filterView.reloadData()
        }
    }

    let filterView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(BookFilterCollectionViewCell.self, forCellWithReuseIdentifier: "BookFilterCollectionViewCell")
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        filterView.delegate = self
        filterView.dataSource = self
        configureFilterUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureFilterUI() {
        addSubview(filterView)
        filterView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension BookFilterView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookFilterCollectionViewCell", for: indexPath) as! BookFilterCollectionViewCell
        let list = filters[indexPath.item]
        cell.filterTitle.text = list.name
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        let selectedFilter = filters[indexPath.item]
        delegate?.bookFilterView(self, didSelectFilter: selectedFilter.query)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let list = filters[indexPath.item]
        let text = list.name
        let font = UIFont.systemFont(ofSize: 14)
        let padding: CGFloat = 3
        let textAttributes = [NSAttributedString.Key.font: font]
        let textSize = (text as NSString).size(withAttributes: textAttributes)
        let height: CGFloat = 22
        let width = textSize.width + padding

        return CGSize(width: width, height: height)
    }
}
