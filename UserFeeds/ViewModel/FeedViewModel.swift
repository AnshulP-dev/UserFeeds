//
//  FeedViewModel.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 29/11/20.
//

/**
 View model representing the data that will be displayed to the end user
 */
class FeedViewModel {

    // MARK: - Constants

    private static let bulletString = "\u{2022}"

    // MARK: - Vars

    let title: String
    let subtitle: String
    let feedType: FeedType

    // MARK: - Init

    init(feed: Feed) {
        title = feed.id
        feedType = feed.feedType

        if let date = feed.date, !date.isEmpty {
            subtitle = feed.type + " \(FeedViewModel.bulletString) " + date
        } else {
            subtitle = feed.type
        }
    }
}
