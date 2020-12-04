//
//  ViewController.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 29/11/20.
//

import RealmSwift
import SnapKit

/**
 This is the root view controller of the app. It shows all User Feeds.
 */
class AppRootViewController: UIViewController {

    private enum SegmentType: Int {
        case all
        case text
        case image
        case other
    }

    // MARK: - Constants

    private static let estimatedCellHeight: CGFloat = 600.0

    // MARK: - Instance Vars

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = AppRootViewController.estimatedCellHeight
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
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        return segmentedControl
    }()

    /// It holds view models for all the feeds available to display
    private var allViewModels = [FeedViewModel]()

    /// It holds view models for specific type of feeds e.g. Text, Image, Other, All - based on the user preference selected through Segment Control.
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
                // Got the feeds from Network.
                // 1. Create view models
                // 2. Stop showing loading indicator
                // 3. Filter view models based on SegmentControl segment selection
                // 4. Save feeds in Database
                FeedViewModelProvider.viewModels(for: feeds, completion: { [weak self] (viewModels) in
                    self?.allViewModels = viewModels
                    self?.activityIndicatorView.stopAnimating()
                    self?.filterUserFeeds()
                    RealmDBManager.deleteOldFeedsAndSave(newFeeds: feeds)
                })
            } else {
                // TODO: Show error state. For now, just loading feeds from local DB
                // Didn't get feeds from Network
                // 1. Fetch feeds from DB and create view models
                // 2. Stop showing loading indicator
                // 3. Filter view models based on SegmentControl segment selection
                FeedViewModelProvider.viewModels(for: RealmDBManager.existingFeeds(), completion: { [weak self] (viewModels) in
                    self?.allViewModels = viewModels
                    self?.activityIndicatorView.stopAnimating()
                    self?.filterUserFeeds()
                })
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

        if let viewModel = filteredViewModels[safe: indexPath.row] {
            cell.setup(with: viewModel)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension AppRootViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = filteredViewModels[safe: indexPath.row] else {
            assertionFailure("Trying to access data from \"out of bounds index\"")
            return
        }

        let detailViewController = FeedDetailViewController(viewModel: viewModel)
        navigationController?.pushViewController(detailViewController, animated: true)
    }
}
