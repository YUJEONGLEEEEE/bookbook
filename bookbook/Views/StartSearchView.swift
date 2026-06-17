
import UIKit
import SnapKit

final class StartSearchView: UIView {

    weak var delegate: StartSearchProtocol?

    private var recentSearches: [String] = []
    private var popularSearches: [String] = []
    private var isEmptyResult = false

    private lazy var SearchedCollectionView: UICollectionView = {
        let layout = LeftAlignedFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
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
        isEmptyResult = show
        emptyResultLabel.isHidden = !show
        SearchedCollectionView.reloadData()
    }

    private func configureUI() {
        backgroundColor = .clear
        addSubviews([SearchedCollectionView, emptyResultLabel])

        SearchedCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalToSuperview()
        }

        emptyResultLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension StartSearchView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return isEmptyResult ? 0 : min(5, recentSearches.count)
        } else {
            return min(5, popularSearches.count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentSearchedCollectionViewCell", for: indexPath) as! RecentSearchedCollectionViewCell
            let text = recentSearches[indexPath.item]
            cell.wordLabel.text = text
            cell.deleteAction = { [weak self, weak cell] in
                guard
                    let self,
                    let cell,
                    let currentIndexPath = collectionView.indexPath(for: cell),
                    currentIndexPath.section == 0   // 최근 검색어 섹션만 삭제 (인기 키워드 보호)
                else { return }
                self.delegate?.didDeleteRecentSearch(at: currentIndexPath.item)
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
            let popularTitle = isEmptyResult ? "인기 키워드를 확인해보세요" : "인기 키워드"
            let titles = ["최근 검색어", popularTitle]
            header.configure(title: titles[indexPath.section])
            return header
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 && isEmptyResult { return .zero }
        return CGSize(width: collectionView.frame.width, height: 44)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let font = UIFont.customFont(ofSize: 14, weight: .medium)
        let height: CGFloat = 33

        if indexPath.section == 0 {
            // 최근 검색어: 좌16 + 텍스트 + 간격6 + X버튼16 + 우12
            let text = recentSearches[indexPath.item]
            let w = (text as NSString).size(withAttributes: [.font: font]).width
            return CGSize(width: ceil(w) + 50, height: height)
        } else {
            // 인기 키워드: "#텍스트" + 좌우 16씩
            let text = "#\(popularSearches[indexPath.item])"
            let w = (text as NSString).size(withAttributes: [.font: font]).width
            return CGSize(width: ceil(w) + 32, height: height)
        }
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

// 칩 왼쪽 정렬 레이아웃
final class LeftAlignedFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributes = super.layoutAttributesForElements(in: rect) else { return nil }
        let copied = attributes.map { $0.copy() as! UICollectionViewLayoutAttributes }

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        for attr in copied {
            guard attr.representedElementCategory == .cell else { continue }   // 헤더는 그대로
            if attr.frame.origin.y >= maxY {
                leftMargin = sectionInset.left                                  // 새 줄 시작
            }
            attr.frame.origin.x = leftMargin
            leftMargin += attr.frame.width + minimumInteritemSpacing
            maxY = max(attr.frame.maxY, maxY)
        }
        return copied
    }
}
