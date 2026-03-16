
import UIKit
import SnapKit

final class StartSearchView: UIView {

    weak var delegate: StartSearchProtocol?

    private var recentSearches: [String] = []
    private var popularSearches: [String] = []

    private lazy var SearchedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 20
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .white
        view.register(RecentSearchedCollectionViewCell.self, forCellWithReuseIdentifier: "RecentSearchedCollectionViewCell")
        view.register(PopularSearchedCollectionViewCell.self, forCellWithReuseIdentifier: "PopularSearchedCollectionViewCell")
        view.register(SearchedHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchedHeaderView")
        return view
    }()

    private let emptyResultLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없습니다"
        label.textColor = .bk3
        label.textAlignment = .center
        label.font = UIFont.customFont(ofSize: 17, weight: .medium)
        label.isHidden = true
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        SearchedCollectionView.delegate = self
        SearchedCollectionView.dataSource = self
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadData(recent: [String], popular: [String]) {
        self.recentSearches = recent
        self.popularSearches = popular
        SearchedCollectionView.reloadData()
    }

    func showEmptyState(_ show: Bool) {
        emptyResultLabel.isHidden = !show
    }

    private func configureUI() {
        backgroundColor = .clear
        addSubviews([SearchedCollectionView, emptyResultLabel])

        SearchedCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(24)
        }

        emptyResultLabel.snp.makeConstraints { make in
            make.top.equalTo(SearchedCollectionView.snp.bottom).offset(100)
            make.centerX.equalToSuperview()
        }
    }
}

extension StartSearchView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return min(5, recentSearches.count)
        } else {
            return min(5, popularSearches.count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentSearchedCollectionViewCell", for: indexPath) as! RecentSearchedCollectionViewCell
            let text = recentSearches[indexPath.item]
            cell.wordLabel.text = text
            cell.deleteAction = { [weak self] in
                self?.delegate?.didDeleteRecentSearch(at: indexPath.item)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularSearchedCollectionViewCell", for: indexPath) as! PopularSearchedCollectionViewCell
            let text = popularSearches[indexPath.item]
            cell.configureKeywordLabel(with: text, index: indexPath.item)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchedHeaderView", for: indexPath) as! SearchedHeaderView
            let titles = ["최근 검색어", "인기 검색어"]
            header.configure(title: titles[indexPath.section])
            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text: String
        if indexPath.section == 0 {
            text = recentSearches[indexPath.item]
        } else {
            text = popularSearches[indexPath.item]
        }
        let font = UIFont.customFont(ofSize: 14, weight: .medium)
        let horizontalPadding: CGFloat = 32
        let textAttributes = [NSAttributedString.Key.font: font]
        let textSize = (text as NSString).size(withAttributes: textAttributes)
        let height: CGFloat = 22

        return CGSize(width: textSize.width + horizontalPadding, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let query: String
        if indexPath.section == 0 {
            query = recentSearches[indexPath.item]
        } else {
            query = popularSearches[indexPath.item]
        }
        delegate?.startSearchView(self, didSelectQuery: query)
    }
}
