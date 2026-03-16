
import UIKit
import Alamofire
import Kingfisher
import SnapKit

class SecondHeaderView: UICollectionReusableView {

    weak var delegate: SecondHeaderProtocol?
    private var rankedBooks: [Book] = []

    private let secondSectionTitle: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "이번주 많은 마음을 받은 책이에요"
        label.font = UIFont.customFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.textColor = .bk1
        return label
    }()

    //    사용자 좋아요 기반 랭킹 순위: 1~3위
    let bookRankingCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isHidden = true
        view.backgroundColor = .clear
        view.register(BookRankingCollectionViewCell.self, forCellWithReuseIdentifier: "BookRankingCollectionViewCell")
        return view
    }()

    //    베스트셀러
    let bestsellerCard = BestsellerCardView()

    private let thirdSectionTitle: UILabel = {
        let label = UILabel()
        label.text = "내 책장에 활기를 불어넣을 신간 모음"
        label.font = UIFont.customFont(ofSize: 20, weight: .bold)
        label.textAlignment = .left
        label.textColor = .bk1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        bookRankingCollectionView.delegate = self
        bookRankingCollectionView.dataSource = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureRandomBestseller(coverImage: UIImage?, blurImage: UIImage?, title: String?, descripton: String?) {
        bestsellerCard.configure(
            coverImage: coverImage,
            blurImage: blurImage,
            title: title,
            description: descripton ?? "베스트셀러 추천 도서입니다!"
        )
    }

    func resetBestseller() {
        bestsellerCard.reset()
    }

    func updateBookRankings(books: [Book]) {
        self.rankedBooks = books
        bookRankingCollectionView.reloadData()

        let hasRankedBooks = !books.isEmpty
        bookRankingCollectionView.isHidden = !hasRankedBooks
        secondSectionTitle.isHidden = !hasRankedBooks
    }

    private func configureUI() {
        self.addSubviews([secondSectionTitle, bookRankingCollectionView, bestsellerCard, thirdSectionTitle])
        secondSectionTitle.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.top.equalToSuperview().offset(50)
        }
        bookRankingCollectionView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.top.equalTo(secondSectionTitle.snp.bottom).offset(20)
//            make.height.equalTo(100)
        }
        bestsellerCard.snp.makeConstraints { make in
            make.height.equalTo(415)
            make.width.equalTo(354)
            make.top.equalTo(bookRankingCollectionView.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
        }
        thirdSectionTitle.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.top.equalTo(bestsellerCard.snp.bottom).offset(40)
        }
    }
}

extension SecondHeaderView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(rankedBooks.count, 3)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookRankingCollectionViewCell", for: indexPath) as! BookRankingCollectionViewCell
        let book = rankedBooks[indexPath.item]
        if let imageString = book.image,
           !imageString.isEmpty,
           let url = URL(string: imageString) {
            cell.bookImage.kf.setImage(with: url)
        } else {
            cell.bookImage.image = UIImage(named: "icon_placeholder")
        }
        cell.bookRank.text = "\(indexPath.row + 1)"
        let author = book.author ?? ""
        let publisher = book.publisher ?? ""
        cell.bookAuthorPublisher.text = "\(author) · \(publisher)"

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function)
        delegate?.secondHeaderView(self, didSelectItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: 112)
    }
}
