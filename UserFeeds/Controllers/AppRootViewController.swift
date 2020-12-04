//
//  ViewController.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 29/11/20.
//

import SnapKit

class AppRootViewController: UIViewController {

    private enum SegmentType: Int {
        case all
        case text
        case image
        case other
    }

    // MARK: - Instance Vars

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.tableFooterView = UIView()
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.reuseID)
        return tableView
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.hidesWhenStopped = true
        view.addSubview(indicatorView)
        return indicatorView
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let items = [
            NSLocalizedString("All", comment: ""),
            NSLocalizedString("Text", comment: ""),
            NSLocalizedString("Image", comment: ""),
            NSLocalizedString("Other", comment: "")
        ]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.backgroundColor = .orange
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()

    private var allViewModels = [FeedViewModel]()
    private var filteredViewModels = [FeedViewModel]()

    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        fetchUserFeeds()
        tableView.reloadData()
    }

    // MARK: - Private Helpers

    private func setupViews() {
        view.addSubview(tableView)
        navigationItem.titleView = segmentedControl
    }

    private func setupConstraints() {
        tableView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        activityIndicatorView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }

    private func fetchUserFeeds() {
        activityIndicatorView.startAnimating()
        NetworkRequestHelper.fetchUserFeeds { [weak self] (feeds, error) in
            if let feeds = feeds {
                FeedViewModelProvider.viewModels(for: feeds, completion: { [weak self] (viewModels) in
                    self?.allViewModels = viewModels
                    self?.activityIndicatorView.stopAnimating()
                    self?.filterUserFeeds()
                })
            } else {
                // TODO: Show error state. For now, just showing empty cells
                self?.allViewModels = []
                self?.activityIndicatorView.stopAnimating()
                self?.filterUserFeeds()
            }
        }
    }

    private func filterUserFeeds() {
        guard let segmentType = SegmentType(rawValue: segmentedControl.selectedSegmentIndex) else {
            assertionFailure("SegmentType Enum and UISegmentedControl segments are out of sync")
            return
        }

        if segmentType == .all {
            filteredViewModels = allViewModels
            tableView.reloadData()
            return
        }

        filteredViewModels = allViewModels.filter { (viewModel) -> Bool in
            switch viewModel.feedType {
            case .text(_):
                return segmentType == .text
            case .image(_):
                return segmentType == .image
            case .other(_):
                return segmentType == .other
            }
        }
        tableView.reloadData()
    }

    // MARK: - Action Handler

    @objc
    func segmentedControlValueChanged(_ segment: UISegmentedControl) {
        filterUserFeeds()
    }
}

// MARK: - UITableViewDataSource

extension AppRootViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FeedTableViewCell.reuseID) as? FeedTableViewCell else {
            assertionFailure("Cell dequeue request failed")
            return UITableViewCell()
        }

        cell.setup(with: filteredViewModels[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AppRootViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailViewController = FeedDetailViewController(viewModel: filteredViewModels[indexPath.row])
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
