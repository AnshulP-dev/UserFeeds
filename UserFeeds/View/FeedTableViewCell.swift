//
//  FeedTableViewCell.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 29/11/20.
//

import AlamofireImage
import SnapKit

class FeedTableViewCell: UITableViewCell {

    // MARK: - Constants

    private static let contentInset = 16.0
    private static let titleAndSubtitleVerticalPadding = 8.0
    private static let subtitleAndContentVerticalPadding = 16.0
    private static let contentImageViewHeight = 250.0
    private static let contentTextLabelNumberOfLines = 0
    private static let titleLabelNumberOfLines = 0
    private static let titleLabelFont: (name: String, size: CGFloat) = ("Helvetica-Bold", 24.0)
    private static let subtitleLableFont: (name: String, size: CGFloat) = ("CourierNewPSMT", 16.0)
    private static let contentTextLabelFont: (name: String, size: CGFloat) = ("Helvetica-Light", 18.0)
    private static let placeholderImageName = "PlaceholderImage"
    private static let errorImageName = "noImage"
    static let reuseID = String(describing: FeedTableViewCell.self)

    // MARK: - Instance vars and lets

    private let titleLable = UILabel()
    private let subtitleLable = UILabel()
    private let contentTextLabel = UILabel()
    private let contentImageView = UIImageView()
    private var contentTextLabelTopConstraintMaker: ConstraintMakerEditable?
    private var contentImageViewHeightConstraintMaker: ConstraintMakerEditable?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func prepareForReuse() {
        contentTextLabel.text = ""
        contentImageView.image = nil
        contentImageView.af.cancelImageRequest()
    }

    // MARK: - Private Helpers

    private func setupViews() {
        [titleLable,
         subtitleLable,
         contentTextLabel,
         contentImageView].forEach { contentView.addSubview($0) }

        // Title
        titleLable.font = UIFont(name: FeedTableViewCell.titleLabelFont.name, size: FeedTableViewCell.titleLabelFont.size)
        titleLable.numberOfLines = FeedTableViewCell.titleLabelNumberOfLines

        // Subtitle
        subtitleLable.font = UIFont(name: FeedTableViewCell.subtitleLableFont.name, size: FeedTableViewCell.subtitleLableFont.size)

        // Content text label
        contentTextLabel.font = UIFont(name: FeedTableViewCell.contentTextLabelFont.name, size: FeedTableViewCell.contentTextLabelFont.size)
        contentTextLabel.numberOfLines = FeedTableViewCell.contentTextLabelNumberOfLines

        // Content image
        contentImageView.contentMode = .scaleAspectFill
        contentImageView.clipsToBounds = true
    }

    private func setupConstraints() {
        titleLable.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview().inset(FeedTableViewCell.contentInset)
        }

        subtitleLable.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(titleLable)
            make.top.equalTo(titleLable.snp.bottom).offset(FeedTableViewCell.titleAndSubtitleVerticalPadding)
        }

        contentTextLabel.snp.makeConstraints { [weak self] (make) in
            make.leading.trailing.equalTo(titleLable)
            self?.contentTextLabelTopConstraintMaker = make.top.equalTo(subtitleLable.snp.bottom).offset(FeedTableViewCell.subtitleAndContentVerticalPadding)
        }

        contentImageView.snp.makeConstraints { [weak self] (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(contentTextLabel.snp.bottom)
            self?.contentImageViewHeightConstraintMaker = make.height.equalTo(FeedTableViewCell.contentImageViewHeight)
            make.bottom.equalToSuperview().inset(FeedTableViewCell.contentInset)
        }
    }

    private func configureForText(text: String?) {
        contentTextLabel.text = text
        contentImageViewHeightConstraintMaker?.constraint.update(offset: 0)
        contentTextLabelTopConstraintMaker?.constraint.update(offset: (text?.isEmpty ?? true) ? 0 : FeedTableViewCell.subtitleAndContentVerticalPadding)
    }

    private func configureForImage(imageURLString: String?) {
        if let imageURLString = imageURLString, let imageURL = URL(string: imageURLString) {
            contentImageView.af.setImage(
                withURL: imageURL,
                placeholderImage: UIImage(named: FeedTableViewCell.placeholderImageName),
                imageTransition: .crossDissolve(0.3)) { [weak self] (response) in
                if let error = response.error, !error.isRequestCancelledError {
                    self?.contentImageView.image = UIImage(named: FeedTableViewCell.errorImageName)
                }
            }
        } else {
            contentImageView.image = UIImage(named: FeedTableViewCell.errorImageName)
        }

        contentTextLabelTopConstraintMaker?.constraint.update(offset: FeedTableViewCell.subtitleAndContentVerticalPadding)
        contentImageViewHeightConstraintMaker?.constraint.update(offset: FeedTableViewCell.contentImageViewHeight)
    }

    // MARK: - Internal Methods

    func setup(with viewModel: FeedViewModel) {
        titleLable.text = viewModel.title
        subtitleLable.text = viewModel.subtitle

        switch viewModel.feedType {
        case .text(let text):
            configureForText(text: text)
        case .image(let imageURLString):
            configureForImage(imageURLString: imageURLString)
        case .other(let text):
            configureForText(text: text)
        }
    }
}
