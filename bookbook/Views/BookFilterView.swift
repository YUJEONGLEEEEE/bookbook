
import UIKit
import Alamofire
import SnapKit

class BookFilterView: UIView {

    weak var delegate: BookFilterProtocol?

    // 첫 칩 기본 선택 여부 (내책장: true=전체 / 찾기: false=미선택이 전체)
    var autoSelectsFirst: Bool = true
    // 선택된 칩 재탭 시 해제 허용 (찾기에서 '전체'로 돌아가기 위함)
    var allowsDeselect: Bool = false

    var filters: [BookFilter] = [] {
        didSet {
            filterView.reloadData()
            guard autoSelectsFirst else { return }
            // 첫 번째(전체) 칩을 기본 선택 상태로 표시한다.
            DispatchQueue.main.async { [weak self] in
                guard let self, !self.filters.isEmpty else { return }
                self.filterView.selectItem(
                    at: IndexPath(item: 0, section: 0),
                    animated: false,
                    scrollPosition: []
                )
            }
        }
    }

    let filterView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
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

    // 선택된 칩 모두 해제 (= 전체) + 맨 앞으로 스크롤
    func clearSelection() {
        filterView.indexPathsForSelectedItems?.forEach {
            filterView.deselectItem(at: $0, animated: false)
        }
        if filterView.numberOfItems(inSection: 0) > 0 {
            filterView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: false)
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

    // 이미 선택된 칩을 다시 탭하면 해제(= 전체)로 처리
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        if allowsDeselect, collectionView.indexPathsForSelectedItems?.contains(indexPath) == true {
            collectionView.deselectItem(at: indexPath, animated: false)
            delegate?.bookFilterViewDidClearSelection(self)
            return false
        }
        return true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        debugLog(#function)
        let selectedFilter = filters[indexPath.item]
        delegate?.bookFilterView(self, didSelectFilter: selectedFilter)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let list = filters[indexPath.item]
        let text = list.name
        let font = UIFont.customFont(ofSize: 14, weight: .bold)
        // 좌우 패딩 16*2 (선택 시 Bold 기준으로 측정해 글자 잘림 방지)
        let padding: CGFloat = 32
        let textAttributes = [NSAttributedString.Key.font: font]
        let textSize = (text as NSString).size(withAttributes: textAttributes)
        let height: CGFloat = 33
        let width = textSize.width + padding

        return CGSize(width: width, height: height)
    }
}
