//
//  BookmarkViewController.swift
//  bookbook
//
//  Created by 이유정 on 9/16/25.
//

import UIKit
import Alamofire
import Kingfisher
import SnapKit

class BookmarkViewController: UIViewController {

    var bookmarkedBooks: [BookData] = []

    let filterView = BookFilterView()
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        layout.scrollDirection = .vertical
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(BookmarkCollectionViewCell.self, forCellWithReuseIdentifier: "BookmarkCollectionViewCell")
        view.backgroundColor = .clear
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Bookmark"
        collectionView.delegate = self
        collectionView.dataSource = self
        configureUI()
    }

    private func configureUI() {
        view.addSubviews([filterView, collectionView])
        filterView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(filterView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension BookmarkViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
        // pagination 적용해야함
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookmarkCollectionViewCell", for: indexPath) as! BookmarkCollectionViewCell
        let list = bookmarkedBooks[indexPath.item]
        if let url = URL(string: list.image) {
            cell.bookImage.kf.setImage(with: url)
        } else {
            cell.bookImage.image = UIImage(named: "placeholder")
        }
        cell.bookTitle.text = list.title
        cell.authorLabel.text = list.author
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        let detailVC = DetailViewController()
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }

        let itemsPerRow: CGFloat = 1
        let sectionInsets = layout.sectionInset
        let interItemSpacing = layout.minimumInteritemSpacing
        let totalSpacing = sectionInsets.left + sectionInsets.right + (itemsPerRow - 1) * interItemSpacing
        let width = (collectionView.frame.width - totalSpacing) / itemsPerRow

        // cell image
        let imageHeight = width * 4/3

        // cell titleLabel
        let titleText = bookmarkedBooks[indexPath.item].title
        let titleFont = UIFont.systemFont(ofSize: 17)
        let constrainedSize = CGSize(width: width - 20, height: .greatestFiniteMagnitude)
        let titleBoundingBox = titleText.boundingRect(
            with: constrainedSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: titleFont],
            context: nil)
        let titleHeight = ceil(titleBoundingBox.height)

        // cell subLabel
        let descriptionText = bookmarkedBooks[indexPath.item].description
        let descriptionFont = UIFont.systemFont(ofSize: 15)
        let descriptionBoundingBox = descriptionText.boundingRect(
            with: constrainedSize,
            options: .usesLineFragmentOrigin,
            attributes: [.font: descriptionFont],
            context: nil)
        let descriptionHeight = ceil(descriptionBoundingBox.height)

        let cellHeight = imageHeight + titleHeight + descriptionHeight + 12

        return CGSize(width: width, height: cellHeight)
    }
}

/*
 북마크 해제 시 alert창 띄우기
 -> 확인버튼 누르면 reloaddata

 북마크 정렬 순서는 최신 등록순 -> 정렬 변경xxx
 (북마크 버튼 없애기 -> 완료)

 tableView -> collectionView로 변경하기 -> 완료
 */

/*
 >> 추가사항 <<
 디바이스 대응 && 라벨의 글자수에 따른 대응 - 셀 크기 유동적 설정 -> 완료
 */
