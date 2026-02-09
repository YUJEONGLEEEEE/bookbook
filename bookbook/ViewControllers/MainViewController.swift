
import UIKit
import Alamofire
import Kingfisher
import SnapKit

class MainViewController: UIViewController {

    private var preferredBooks: [BookData] = []
    private var recentBooks: [BookData] = []
    private let bookCategory = filters

    private var account: Account?
    private var usersChoices: [String] = []

//    동기화를 위한 lockqueue 추가
    private let bookLockQueue = DispatchQueue(label: "com.readdam.bookdata.lock")

    //    전체페이지 스크롤
    private let refreshControl = UIRefreshControl()
    private let mainScrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.contentInsetAdjustmentBehavior = .automatic
        view.alwaysBounceVertical = true
        return view
    }()

    //    오늘의한문장
    private let quoteCard = QuoteCardView()

    //    이런책은어떠세요 ->> 사용자선호도,연령대,성별 기반
    //    이번주많은마음을받은책이에요 ->> 전체사용자 좋아요 기반
    //    읽담추천 ->> 알라딘 베스트셀러
    //    내책장에활기를불어넣을신간모음 ->> 알라딘 신간
    private let mainCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: "MainCollectionViewCell")
        view.register(FirstHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FirstHeaderView")
        view.register(SecondHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SecondHeaderView")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "logo_color"),
            style: .plain,
            target: self,
            action: #selector(didTapHomeLogo)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            style: .plain,
            target: self,
            action: #selector(searchButtonClicked)
        )
        setupRefreshControl()
        fetchAccountAndConfigure()
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        configureUI()
    }
    @objc private func didTapHomeLogo() {
        print(#function)
        //        홈화면 새로고침
        //        #1 스크롤 최상단 이동
        let topOffset = CGPoint(x: 0, y: -mainScrollView.adjustedContentInset.top)
        mainScrollView.setContentOffset(topOffset, animated: true)
        refreshControl.beginRefreshing()
        handleRefresh()
    }
    @objc private func searchButtonClicked() {
        print(#function)
        self.tabBarController?.selectedIndex = 1
    }

//    account 설정
    private func fetchAccountAndConfigure() {
        guard let account = CoreDataManager.shared.fetchAccount() else {
            usersChoices = ["에세이", "문학"]
            fetchPrefferedBooks(for: usersChoices)
            return
        }
        self.account = account
        configureHome(with: account)
    }

//    사용자 선호도 기반 홈 구성
    private func configureHome(with account: Account) {
        guard let ageRange = AgeRange(rawValue: account.age),
              let gender = Gender(rawValue: account.gender ?? "") else {

            usersChoices = ["에세이", "문학"]
            fetchPrefferedBooks(for: usersChoices)
            return
        }

        let baseGenres = GenreRecommendation.recommendedGenres(
            ageRange: ageRange,
            gender: gender
        )

//        coredatamanager의 fetchGenres() 사용
        let selectedGenres = CoreDataManager.shared.fetchGenres()
        usersChoices = selectedGenres.isEmpty ? baseGenres : selectedGenres

        fetchPrefferedBooks(for: usersChoices)
    }

//    장르 이름으로 categoryId 가져오기
    private func categoryId(for genre: String) -> String? {
        return bookCategory.first(where: { $0.name.contains(genre) })?.categoryId
    }

//    사용자 맞춤 추천 책 가져오기
    private func fetchPrefferedBooks(for genres: [String]) {
        let randomGenres = Array(genres.shuffled().prefix(3))

        guard !randomGenres.isEmpty else {
            DispatchQueue.main.async {
                self.preferredBooks = []
                self.mainCollectionView.reloadSections(IndexSet(integer: 0))
            }
            return
        }

        var genreResults: [[BookData]] = []
        let group = DispatchGroup()

        for genre in randomGenres {
            guard let categoryIdString = categoryId(for: genre),
                  let categoryId = Int(categoryIdString) else {
                continue
            }

            group.enter()
            print("무작위 선택: \(genre) (ID: \(categoryId)) 검색 중...")

            NetworkManager.shared.bookLists(
                queryType: "Bestseller",
                category: categoryId
            ) { result in
                defer { group.leave() }

                let books: [BookData]
                switch result {
                case .success(let bookInfo):
                    books = Array(bookInfo.item.prefix(3))

                case .failure(let error):
                    print("\(genre) 검색 실패: \(error)")
                    books = []
                }

                self.bookLockQueue.async {
                    genreResults.append(books)
                }
            }
        }

        group.notify(queue: .main) {
            let allBooks = genreResults.flatMap { $0 }
            self.preferredBooks = Array(allBooks.shuffled().prefix(10))
            self.mainCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }

    //    스크롤 당겨서 새로고침
    private func setupRefreshControl() {
        print(#function)
        mainScrollView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }
    @objc private func handleRefresh() {
        print(#function)
        //        #1 데이터 다시 불러오기
        fetchAccountAndConfigure()
        //        #2 ui 업데이트
        //        #3 새로고침 종료
        self.refreshControl.endRefreshing()
    }

    private func refrestUserInfo() {
        fetchAccountAndConfigure()
        mainCollectionView.reloadSections(IndexSet(integer: 0))
    }

    private func configureUI() {
        view.addSubview(mainScrollView)
        mainScrollView.addSubviews([quoteCard, mainCollectionView])
        mainScrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        quoteCard.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(364)
        }
        mainCollectionView.snp.makeConstraints { make in
            make.top.equalTo(quoteCard.snp.bottom).offset(56)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SecondHeaderProtocol {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //        님,이런책은어떠세요 && 내책장에활기를넣을신간모음
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
            //            님,이런책은어떠세요
        case 0:
            return min(preferredBooks.count, 10)
            //            내책장에활기를불어넣을신간모음
        case 1:
            return min(recentBooks.count, 10)
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainCollectionViewCell", for: indexPath) as! MainCollectionViewCell
        switch indexPath.section {
        case 0:
            guard indexPath.item < preferredBooks.count else { return cell }
            let pBooks = preferredBooks[indexPath.item]
            if let url = URL(string: pBooks.cover) {
                cell.bookImage.kf.setImage(with: url)
            } else {
                cell.bookImage.image = UIImage(named: "icon_placeholder")
            }
            cell.bookTitle.text = pBooks.title
            cell.bookAuthor.text = pBooks.author

        case 1:
            guard indexPath.item < recentBooks.count else { return cell }
            let rBooks = recentBooks[indexPath.item]
            if let url = URL(string: rBooks.cover) {
                cell.bookImage.kf.setImage(with: url)
            } else {
                cell.bookImage.image = UIImage(named: "icon_placeholder")
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
            let nickname = account?.nickname ?? "_"
            firstHeader.configure(nickname: nickname)
            return firstHeader
            //            좋아요기반 1-3순위
            //            읽담추천
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
            return CGSize(width: collectionView.bounds.width, height: 90)
        case 1:
            return CGSize(width: collectionView.bounds.width, height: <#T##Double#>)
        default:
            return .zero
        }
    }
}
