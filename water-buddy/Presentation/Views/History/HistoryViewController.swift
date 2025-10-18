import UIKit
import Combine

class HistoryViewController: UIViewController {
    var viewModel: HistoryViewModel!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = Constants.Colors.backgroundPrimary
        tableView.separatorStyle = .none
        return tableView
    }()

    private lazy var datePickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.maximumDate = Date()
        picker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return picker
    }()

    private lazy var emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private lazy var emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "drop.fill")
        imageView.tintColor = Constants.Colors.textTertiary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textSecondary
        label.textAlignment = .center
        label.text = NSLocalizedString("history.no_entries", value: "No entries found", comment: "")
        return label
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupNavigationBar()
        registerTableViewCells()
        setupNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.loadEntries()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = Constants.Colors.backgroundPrimary

        view.addSubview(datePickerView)
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        view.addSubview(loadingIndicator)

        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            datePickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Dimensions.paddingMedium),
            datePickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Dimensions.paddingLarge),
            datePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Dimensions.paddingLarge),

            tableView.topAnchor.constraint(equalTo: datePickerView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 60),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 60),

            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: Constants.Dimensions.paddingMedium),
            emptyStateLabel.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupNavigationBar() {
        navigationItem.title = NSLocalizedString("history.title", value: "History", comment: "")
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(waterIntakeUpdated),
            name: Notification.Name("WaterIntakeUpdated"),
            object: nil
        )
    }
    
    @objc private func waterIntakeUpdated(_ notification: Notification) {
        // Reload entries when water is added
        viewModel.loadEntries()
    }

    private func registerTableViewCells() {
        tableView.register(WaterEntryCell.self, forCellReuseIdentifier: WaterEntryCell.identifier)
    }

    private func setupBindings() {
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)

        viewModel.$waterEntries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] entries in
                self?.tableView.reloadData()
                self?.emptyStateView.isHidden = !entries.isEmpty
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showAlert(title: NSLocalizedString("alert.error", value: "Error", comment: ""), message: error)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    @objc private func dateChanged() {
        viewModel.loadEntries(for: datePickerView.date)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.waterEntries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WaterEntryCell.identifier, for: indexPath) as! WaterEntryCell
        let entry = viewModel.waterEntries[indexPath.row]
        cell.configure(with: entry)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.Dimensions.cellHeight
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let entry = viewModel.waterEntries[indexPath.row]
            showConfirmationAlert(
                title: NSLocalizedString("history.delete_entry", value: "Delete Entry", comment: ""),
                message: NSLocalizedString("history.delete_confirmation", value: "Are you sure you want to delete this entry?", comment: "")
            ) {
                self.viewModel.deleteEntry(id: entry.id)
            }
        }
    }
}

// MARK: - Water Entry Cell

class WaterEntryCell: UITableViewCell {
    static let identifier = "WaterEntryCell"

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Constants.Colors.backgroundSecondary
        view.layer.cornerRadius = Constants.Dimensions.smallCornerRadius
        return view
    }()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = Constants.Colors.primaryBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.headline
        label.textColor = Constants.Colors.textPrimary
        return label
    }()

    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textSecondary
        return label
    }()

    private lazy var containerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = FontManager.shared.caption1
        label.textColor = Constants.Colors.textSecondary
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }

    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)
        containerView.addSubview(iconImageView)
        containerView.addSubview(amountLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(containerLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constants.Dimensions.paddingMedium),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),

            amountLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: Constants.Dimensions.paddingMedium),
            amountLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constants.Dimensions.paddingSmall),

            timeLabel.leadingAnchor.constraint(equalTo: amountLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 2),

            containerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constants.Dimensions.paddingMedium),
            containerLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            containerLabel.leadingAnchor.constraint(greaterThanOrEqualTo: amountLabel.trailingAnchor, constant: Constants.Dimensions.paddingMedium)
        ])
    }

    func configure(with entry: WaterEntry) {
        iconImageView.image = UIImage(systemName: entry.containerType.systemImageName)
        amountLabel.text = "\(Int(entry.amount)) \(entry.unit.symbol)"
        timeLabel.text = entry.timestamp.formattedTimeString()
        containerLabel.text = entry.containerType.displayName
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        amountLabel.text = nil
        timeLabel.text = nil
        containerLabel.text = nil
    }
}