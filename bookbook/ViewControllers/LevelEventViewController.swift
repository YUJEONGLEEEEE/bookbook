import UIKit
import SnapKit
import Kingfisher
import ImageIO

final class LevelEventViewController: UIViewController {

    private var didProcess = false
    private var currentEarnedCount = 0
    private var playingLevel = 0             // 현재 재생 중인 gif의 권수
    private var gifCompletion: (() -> Void)?
    private var gifTimeoutWorkItem: DispatchWorkItem?   // gif 완료 타임아웃(보류 시 취소)
    private var lastFrameCache: [Int: UIImage] = [:]   // gif 마지막 프레임 캐시

    private let backgroundImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "event_backgroundimage")
        view.clipsToBounds = true
        return view
    }()

    private let goalLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(ofSize: 17, weight: .medium)
        label.textColor = .bk1
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // 책탑 (gif 애니메이션 + 정적 이미지 공용)
    private let towerView: AnimatedImageView = {
        let view = AnimatedImageView()
        view.contentMode = .scaleAspectFit
        view.repeatCount = .once
        return view
    }()

    // MARK: 진행 게이지 카드
    private let gaugeCard: UIView = {
        let view = UIView()
        view.backgroundColor = .customWh
        view.layer.cornerRadius = 8
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowRadius = 8
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        return view
    }()

    private let track: UIView = {
        let view = UIView()
        view.backgroundColor = .bk4
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    private let fill: UIView = {
        let view = UIView()
        view.backgroundColor = .sub01
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()

    private let doneLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(ofSize: 12, weight: .medium)
        label.textColor = .sub01
        return label
    }()

    private let nextLabel: UILabel = {
        let label = UILabel()
        label.font = .customFont(ofSize: 12, weight: .medium)
        label.textColor = .bk2
        return label
    }()

    // 하단 탭바 숨김
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        hidesBottomBarWhenPushed = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "책탑쌓기"
        setupDefaultBackButton()
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProgress()
    }

    private func loadProgress() {
        CoreDataManager.shared.fetchComments { [weak self] comments in
            self?.applyProgress(writtenCount: comments.count)
        }
    }

    private func applyProgress(writtenCount: Int) {
        let earned = BookReward.earned(for: writtenCount)
        currentEarnedCount = earned.count

        updateGoalLabel(latest: earned.last)
        updateGaugeLabels(writtenCount: writtenCount)

        // 새로 획득한 보상 찾기
        let ack = LevelRewardStore.acknowledged()
        let newlyEarned = earned.filter { !ack.contains($0.count) }

        // 한 방문에서 연출은 한 번만
        guard !didProcess else {
            setGauge(ratio: levelRatio(writtenCount: writtenCount), animated: false)
            showStaticTower(level: earned.count)
            Self.saveLastShownCount(writtenCount)
            return
        }
        didProcess = true

        if newlyEarned.isEmpty {
            // 새 책 없는 평소 방문: 직전에 보여준 위치에서 새로 추가된 책한줄 만큼만 차오름
            // (첫 방문은 0부터, 이후 방문은 증가분만큼)
            showStaticTower(level: earned.count)
            setGauge(ratio: previousLevelRatio(earnedCount: earned.count, writtenCount: writtenCount), animated: false)
            setGauge(ratio: levelRatio(writtenCount: writtenCount), animated: true)
            Self.saveLastShownCount(writtenCount)
        } else {
            let startEarned = earned.count - newlyEarned.count
            setGauge(ratio: 0, animated: false)
            showStaticTower(level: startEarned)
            runRewardSequence(newlyEarned, finalWrittenCount: writtenCount)
        }
    }

    // 직전에 게이지로 보여준 작성 수 (방문 간 증가분만 차오르게 하기 위함)
    // 계정별로 분리
    private static var lastGaugeCountKey: String { UserSession.scopedKey("levelEventLastShownCount") }
    private static func saveLastShownCount(_ count: Int) {
        UserDefaults.standard.set(count, forKey: lastGaugeCountKey)
    }
    private static func lastShownCount() -> Int {
        UserDefaults.standard.integer(forKey: lastGaugeCountKey)
    }
    // 회원탈퇴 시 게이지 진행 기록 초기화
    static func clearProgress() {
        UserDefaults.standard.removeObject(forKey: lastGaugeCountKey)
    }

    // 직전에 보여준 작성 수를 현재 레벨 기준 비율로 환산 → 애니메이션 시작점
    private func previousLevelRatio(earnedCount: Int, writtenCount: Int) -> CGFloat {
        let last = Self.lastShownCount()
        // 기록이 없거나(첫 방문) 현재보다 큰 경우(삭제 등) 0부터
        guard last > 0, last <= writtenCount else { return 0 }
        let thresholds = BookReward.cumulativeThresholds()
        let prevCumulative = earnedCount > 0 ? thresholds[earnedCount - 1] : 0
        guard last >= prevCumulative else { return 0 }   // 직전 기록이 현재 레벨 시작 이전이면 0부터
        let required = earnedCount < BookReward.all.count ? BookReward.all[earnedCount].count : 1
        let inLevel = last - prevCumulative
        return required > 0 ? min(1.0, max(0.0, CGFloat(inLevel) / CGFloat(required))) : 0
    }

    // 보상 연출 시퀀스 (게이지 → gif → 팝업)
    private func runRewardSequence(_ rewards: [BookReward], finalWrittenCount: Int) {
        var queue = rewards
        func step() {
            guard !queue.isEmpty else {
                updateGoalLabel(latest: BookReward.earned(for: finalWrittenCount).last)
                updateGaugeLabels(writtenCount: finalWrittenCount)
                setGauge(ratio: 0, animated: false)
                setGauge(ratio: levelRatio(writtenCount: finalWrittenCount), animated: true)
                Self.saveLastShownCount(finalWrittenCount)
                return
            }
            let reward = queue.removeFirst()
            let level = (BookReward.all.firstIndex { $0.count == reward.count } ?? 0) + 1
            let required = reward.count

            goalLabel.text = "목표 달성! \(reward.name)\(reward.name.objectParticle) 획득했어요."
            setGaugeLabels(done: 0, requirement: required)
            setGauge(ratio: 0, animated: false)
            // ① 게이지 0 → 가득
            setGauge(ratio: 1.0, animated: true) { [weak self] in
                guard let self else { return }
                self.setGaugeLabels(done: required, requirement: required)
                // ② gif 재생
                self.playTowerGif(level: level) { [weak self] in
                    guard let self else { return }
                    // ③ 팝업
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
                        guard let self else { return }
                        // 연출 도중 뒤로가기 등으로 화면을 벗어났으면 present 시도하지 않음
                        // (acknowledge하지 않으므로 다음 진입 시 연출이 다시 재생됨)
                        guard self.viewIfLoaded?.window != nil else { return }
                        let popup = BookRewardPopUpViewController(reward: reward)
                        popup.onConfirm = {
                            LevelRewardStore.markAcknowledged([reward.count])
                            step()
                        }
                        self.present(popup, animated: true)
                    }
                }
            }
        }
        step()
    }

    private func setGaugeLabels(done: Int, requirement: Int) {
        doneLabel.text = "\(done)번 완료"
        nextLabel.text = "책한줄 \(requirement)번 작성"
    }

    // MARK: - 상단 문구 / 게이지 라벨
    private func updateGoalLabel(latest: BookReward?) {
        if let latest {
            goalLabel.text = "목표 달성! \(latest.name)\(latest.name.objectParticle) 획득했어요."
        } else {
            goalLabel.text = "책한줄을 작성하고 첫 번째 책을 받아보세요!"
        }
    }

    private func updateGaugeLabels(writtenCount: Int) {
        let earnedCount = BookReward.earned(for: writtenCount).count
        if let next = BookReward.next(after: writtenCount) {
            let thresholds = BookReward.cumulativeThresholds()
            let prevCumulative = earnedCount > 0 ? thresholds[earnedCount - 1] : 0
            doneLabel.text = "\(writtenCount - prevCumulative)번 완료"
            nextLabel.text = "책한줄 \(next.count)번 작성"
        } else {
            doneLabel.text = "최고 단계 달성!"
            nextLabel.text = ""
        }
    }

    // MARK: - 게이지 비율 (한 레벨당 게이지 하나: 현재 레벨의 0→100%)
    private func levelRatio(writtenCount: Int) -> CGFloat {
        let earnedCount = BookReward.earned(for: writtenCount).count
        if earnedCount >= BookReward.all.count { return 1.0 }   // 모든 레벨 완료
        let thresholds = BookReward.cumulativeThresholds()
        let prevCumulative = earnedCount > 0 ? thresholds[earnedCount - 1] : 0
        let required = BookReward.all[earnedCount].count        // 현 레벨에서 필요한 횟수
        let inLevel = writtenCount - prevCumulative             // 현 레벨에서 작성한 횟수
        return required > 0 ? min(1.0, max(0.0, CGFloat(inLevel) / CGFloat(required))) : 0
    }

    private func setGauge(ratio: CGFloat, animated: Bool, completion: (() -> Void)? = nil) {
        fill.snp.remakeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
            make.width.equalTo(track).multipliedBy(max(0.0001, min(1.0, ratio)))
        }
        if animated {
            UIView.animate(withDuration: 1.4, delay: 0, options: .curveEaseInOut,
                           animations: { self.view.layoutIfNeeded() },
                           completion: { _ in completion?() })
        } else {
            view.layoutIfNeeded()
            completion?()
        }
    }

    // MARK: 책탑 표시
    // gif 마지막 프레임을 정적으로 표시 (gif 끝과 위치 동일)
    private func showStaticTower(level: Int) {
        towerView.stopAnimating()
        towerView.kf.cancelDownloadTask()
        towerView.image = towerLastFrame(level: level)
    }

    private func towerLastFrame(level: Int) -> UIImage? {
        guard level >= 1, level <= 9 else { return nil }
        if let cached = lastFrameCache[level] { return cached }
        guard let url = Bundle.main.url(forResource: String(format: "booktop_ani_%02d", level), withExtension: "gif"),
              let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
        let count = CGImageSourceGetCount(source)
        guard count > 0, let cg = CGImageSourceCreateImageAtIndex(source, count - 1, nil) else { return nil }
        let image = UIImage(cgImage: cg)
        lastFrameCache[level] = image
        return image
    }

    private func playTowerGif(level: Int, completion: @escaping () -> Void) {
        guard level >= 1, level <= 9,
              let url = Bundle.main.url(forResource: String(format: "booktop_ani_%02d", level), withExtension: "gif") else {
            showStaticTower(level: level)
            completion()
            return
        }
        playingLevel = level
        gifCompletion = completion
        towerView.delegate = self
        towerView.repeatCount = .once
        towerView.kf.setImage(with: LocalFileImageDataProvider(fileURL: url))
        // gif 디코드 실패 등으로 완료 델리게이트가 안 불릴 경우를 대비한 타임아웃 폴백
        // (이전 보상의 타임아웃이 다음 gif를 조기 종료하지 않도록 WorkItem으로 취소 가능하게 함)
        gifTimeoutWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.finishTowerGif() }
        gifTimeoutWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: work)
    }

    // gif 완료 처리(델리게이트 또는 타임아웃 중 먼저 도달한 쪽 1회만 실행)
    private func finishTowerGif() {
        gifTimeoutWorkItem?.cancel()
        gifTimeoutWorkItem = nil
        guard let completion = gifCompletion else { return }
        gifCompletion = nil
        showStaticTower(level: playingLevel)
        completion()
    }

    private func configureUI() {
        view.addSubviews([backgroundImage, towerView, goalLabel, gaugeCard])
        gaugeCard.addSubviews([track, doneLabel, nextLabel])
        track.addSubview(fill)

        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        goalLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        gaugeCard.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
            make.height.equalTo(90)
        }
        // 책탑: 전체 폭 + GIF 비율(804:1320) 유지, 책더미 바닥(=캔버스 바닥)을 게이지 카드 위 48pt에 고정
        towerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(towerView.snp.width).multipliedBy(1320.0 / 804.0)
            make.bottom.equalTo(gaugeCard.snp.top).offset(-48)
        }
        track.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(32)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(8)
        }
        fill.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
            make.width.equalTo(0)
        }
        // 라벨은 트랙 아래, 좌/우 끝을 트랙에 맞춤
        doneLabel.snp.makeConstraints { make in
            make.top.equalTo(track.snp.bottom).offset(4)
            make.leading.equalTo(track)
        }
        nextLabel.snp.makeConstraints { make in
            make.centerY.equalTo(doneLabel)
            make.trailing.equalTo(track)
        }
    }
}

// MARK: - gif 재생 완료 감지
extension LevelEventViewController: AnimatedImageViewDelegate {
    func animatedImageView(_ imageView: AnimatedImageView, didPlayAnimationLoops count: UInt) {
        finishTowerGif()
    }
}
