//
//  FeedDetailViewController.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 30/11/20.
//

import SnapKit

class FeedDetailViewController: UIViewController {

    // MARK: - Constants

    private static let contentInset: CGFloat = 16.0
    private static let interitemSpacing: CGFloat = 16.0
    private static let titleLabelNumberOfLines = 0
    private static let contentTextLabelNumberOfLines = 0
    private static let titleLabelFont: (name: String, size: CGFloat) = ("Helvetica-Bold", 24.0)
    private static let subtitleLableFont: (name: String, size: CGFloat) = ("CourierNewPSMT", 16.0)
    private static let contentTextLabelFont: (name: String, size: CGFloat) = ("Helvetica-Light", 18.0)
    private static let placeholderImageName = "PlaceholderImage"
    private static let errorImageName = "noImage"

    // MARK: - Instance Vars

    private let contentStackView = UIStackView()
    private let scrollView = UIScrollView()
    private let feedViewModel: FeedViewModel
    private var contentImageViewHeightConstraintMaker: ConstraintMakerEditable?

    // MARK: - Init

    init(viewModel: FeedViewModel) {
        feedViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
    }

    // MARK: - Private Helpers

    private func setupViews() {
        view.backgroundColor = .white
        navigationItem.title = NSLocalizedString("Feed Detail", comment: "")
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 2 * FeedDetailViewController.contentInset, right: 0)
        view.addSubview(scrollView)
        contentStackView.axis = .vertical
        contentStackView.spacing = FeedDetailViewController.interitemSpacing
        scrollView.addSubview(contentStackView)

        // Title
        let titleLable = UILabel()
        titleLable.font = UIFont(name: FeedDetailViewController.titleLabelFont.name, size: FeedDetailViewController.titleLabelFont.size)
        titleLable.numberOfLines = FeedDetailViewController.titleLabelNumberOfLines
        titleLable.text = feedViewModel.title
        contentStackView.addArrangedSubview(titleLable)

        // Subtitle
        let subtitleLable = UILabel()
        subtitleLable.font = UIFont(name: FeedDetailViewController.subtitleLableFont.name, size: FeedDetailViewController.subtitleLableFont.size)
        subtitleLable.text = feedViewModel.subtitle
        contentStackView.addArrangedSubview(subtitleLable)

        // Content view
        switch feedViewModel.feedType {
        case .text(let text):
            let contentTextLabel = UILabel()
            contentTextLabel.font = UIFont(name: FeedDetailViewController.contentTextLabelFont.name, size: FeedDetailViewController.contentTextLabelFont.size)
            contentTextLabel.numberOfLines = FeedDetailViewController.contentTextLabelNumberOfLines
            contentTextLabel.text = text
            contentStackView.addArrangedSubview(contentTextLabel)
        case .image(let imageURLString):
            let contentImageView = UIImageView()
            contentImageView.contentMode = .scaleAspectFit
            contentImageView.clipsToBounds = true
            contentStackView.addArrangedSubview(contentImageView)

            contentImageView.snp.makeConstraints { (make) in
                make.width.equalToSuperview()
                contentImageViewHeightConstraintMaker = make.height.equalTo(200)
            }

            if let imageURLString = imageURLString, let imageURL = URL(string: imageURLString) {
                contentImageView.af.setImage(
                    withURL: imageURL,
                    placeholderImage: UIImage(named: FeedDetailViewController.placeholderImageName),
                    imageTransition: .crossDissolve(0.3)) { [weak self] (response) in
                    guard let strongSelf = self else { return }
                    if response.error != nil {
                        contentImageView.image = UIImage(named: FeedDetailViewController.errorImageName)
                    }

                    if let image = contentImageView.image {
                        let imageHeightToWidthRatio = image.size.height / image.size.width
                        strongSelf.contentImageViewHeightConstraintMaker?.constraint.update(offset: imageHeightToWidthRatio * strongSelf.boundingWidth())
                    }
                }
            } else {
                contentImageView.image = UIImage(named: FeedDetailViewController.errorImageName)
            }

        case .other(let text):
            let contentTextLabel = UILabel()
            contentTextLabel.font = UIFont(name: FeedDetailViewController.contentTextLabelFont.name, size: FeedDetailViewController.contentTextLabelFont.size)
            contentTextLabel.numberOfLines = FeedDetailViewController.contentTextLabelNumberOfLines
            contentTextLabel.text = text
            contentStackView.addArrangedSubview(contentTextLabel)
        }

    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        contentStackView.snp.makeConstraints { (make) in
            make.leading.trailing.top.bottom.equalToSuperview().offset(FeedDetailViewController.contentInset)
            make.width.equalToSuperview().inset(FeedDetailViewController.contentInset)
        }
    }

    private func boundingWidth() -> CGFloat {
        return view.bounds.width - 2 * FeedDetailViewController.contentInset
    }
}
