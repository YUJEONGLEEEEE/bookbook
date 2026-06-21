
import UIKit
import SnapKit

// MARK: - Model
struct QnaItem {
    let date: String
    let question: String
    let questionBody: String
    let answer: String?          // nil = 답변대기
    var isAnswered: Bool { answer != nil }
}

class QnAViewController: UIViewController {

    private let sampleBody = "내책장에 책을 담았는데 취소하고 싶어요.\n매번 책 눌러서 들어가서 취소하기 귀찮은데 쉽게 하는방법 없나요?"
    private let sampleAnswer = "안녕하세요.\n책과 대화하는 앱, 읽담입니다.\n\n언제나 읽담을 사랑해주셔서 감사드립니다.\n\n내책장에 담긴 책을 누른채 오른쪽으로 스와이프하면 책 상세페이지에 들어가지 않고도 바로 취소하기가 가능합니다. 해당 기능으로 쉽고 편리하게 읽담을 사용해주세요.\n\n감사합니다."

    private lazy var items: [QnaItem] = [
        QnaItem(date: "2026.03.30", question: "내책장 취소 어떻게 하나요?", questionBody: sampleBody, answer: nil),
        QnaItem(date: "2026.03.18", question: "내책장 취소 어떻게 하나요?", questionBody: sampleBody, answer: sampleAnswer),
        QnaItem(date: "2026.03.01", question: "내책장 취소 어떻게 하나요?", questionBody: sampleBody, answer: sampleAnswer)
    ]
    private var expandedRows = Set<Int>()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "내 문의 내역"
        label.font = UIFont.customFont(ofSize: 18, weight: .bold)
        label.textColor = .bk1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "영업일 기준 3일 이내로 답변드릴게요."
        label.font = UIFont.customFont(ofSize: 14, weight: .medium)
        label.textColor = .bk3
        return label
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "아직 남겨주신 문의 내역이 없어요"
        label.font = UIFont.customFont(ofSize: 16, weight: .medium)
        label.textColor = .bk3
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let tableView: UITableView = {
        let view = UITableView()
        view.register(QnaTableViewCell.self, forCellReuseIdentifier: QnaTableViewCell.id)
        view.separatorStyle = .none
        view.rowHeight = UITableView.automaticDimension
        view.estimatedRowHeight = 90
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWh
        navigationItem.title = "1:1 문의"
        configureWriteButton()
        tableView.delegate = self
        tableView.dataSource = self
        configureUI()
        updateEmptyState()
    }

    private func configureWriteButton() {
        let writeButton = UIButton(type: .system)
        writeButton.setTitle("작성", for: .normal)
        writeButton.setTitleColor(.customBtn, for: .normal)
        writeButton.titleLabel?.font = UIFont.customFont(ofSize: 16, weight: .medium)
        writeButton.addTarget(self, action: #selector(writeTapped), for: .touchUpInside)
        let item = UIBarButtonItem(customView: writeButton)
        if #available(iOS 26.0, *) {
            item.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = item
    }

    @objc private func writeTapped() {
        let formVC = QnAFormViewController()
        formVC.onSubmit = { [weak self] item in
            guard let self else { return }
            self.items.insert(item, at: 0)
            self.expandedRows = Set(self.expandedRows.map { $0 + 1 })
            self.tableView.reloadData()
            self.updateEmptyState()
        }
        navigationController?.pushViewController(formVC, animated: true)
    }

    private func updateEmptyState() {
        let isEmpty = items.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }

    private func configureUI() {
        view.addSubviews([headerLabel, subtitleLabel, tableView, emptyLabel])

        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.leading.equalToSuperview().offset(24)
        }
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(6)
            make.leading.equalToSuperview().offset(24)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(20)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-40)
        }
    }
}

// MARK: - UITableView
extension QnAViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QnaTableViewCell.id, for: indexPath) as! QnaTableViewCell
        cell.configure(item: items[indexPath.row], isExpanded: expandedRows.contains(indexPath.row))
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedRows.contains(indexPath.row) {
            expandedRows.remove(indexPath.row)
        } else {
            expandedRows.insert(indexPath.row)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - Cell (펼침 토글)
final class QnaTableViewCell: UITableViewCell {

    static let id = "QnaTableViewCell"

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 13, weight: .medium)
        label.textColor = .bk3
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 13, weight: .medium)
        label.textAlignment = .right
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 16, weight: .bold)
        label.textColor = .bk1
        label.numberOfLines = 1
        return label
    }()

    private let chevron: UIImageView = {
        let view = UIImageView()
        view.tintColor = .bk2
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 15, weight: .medium)
        label.textColor = .bk1
        label.numberOfLines = 0
        return label
    }()

    private let answerSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .bk5
        view.snp.makeConstraints { $0.height.equalTo(1) }
        return view
    }()

    private let answerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.customFont(ofSize: 15, weight: .medium)
        label.textColor = .bk2
        label.numberOfLines = 0
        return label
    }()

    private let headerView = UIView()

    private let expandedView: UIView = {
        let view = UIView()
        view.backgroundColor = .sub02
        return view
    }()

    private lazy var contentStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [questionLabel, answerSeparator, answerLabel])
        view.axis = .vertical
        view.spacing = 16
        view.alignment = .fill
        return view
    }()

    private lazy var mainStack: UIStackView = {
        let view = UIStackView(arrangedSubviews: [headerView, expandedView])
        view.axis = .vertical
        view.spacing = 0
        return view
    }()

    private let bottomLine: UIView = {
        let view = UIView()
        view.backgroundColor = .bk6
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        headerView.addSubviews([dateLabel, statusLabel, titleLabel, chevron])
        dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalToSuperview().offset(24)
        }
        statusLabel.snp.makeConstraints { make in
            make.centerY.equalTo(dateLabel)
            make.trailing.equalToSuperview().inset(24)
            make.leading.greaterThanOrEqualTo(dateLabel.snp.trailing).offset(8)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(dateLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(24)
            make.bottom.equalToSuperview().inset(16)
        }
        chevron.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalToSuperview().inset(24)
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            make.size.equalTo(16)
        }

        expandedView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(32)
            make.horizontalEdges.equalToSuperview().inset(24)
        }

        contentView.addSubviews([mainStack, bottomLine])
        mainStack.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        bottomLine.snp.makeConstraints { make in
            make.top.equalTo(mainStack.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }

    func configure(item: QnaItem, isExpanded: Bool) {
        dateLabel.text = item.date
        titleLabel.text = item.question
        statusLabel.text = item.isAnswered ? "답변완료" : "답변대기"
        statusLabel.textColor = item.isAnswered ? .sub01 : .bk3

        let symbol = isExpanded ? "chevron.up" : "chevron.down"
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        chevron.image = UIImage(systemName: symbol, withConfiguration: config)

        expandedView.isHidden = !isExpanded
        questionLabel.text = item.questionBody

        let answered = item.answer != nil
        answerSeparator.isHidden = !answered
        answerLabel.isHidden = !answered
        answerLabel.text = item.answer
    }
}
