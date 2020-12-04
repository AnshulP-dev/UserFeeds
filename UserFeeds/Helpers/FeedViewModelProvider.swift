//
//  FeedViewModelProvider.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 29/11/20.
//

import Foundation

class FeedViewModelProvider {

    typealias ViewModelProviderCompletionHandler = ([FeedViewModel]) -> Void

    // MARK: - Constants

    private static let viewModelProviderQueue = DispatchQueue(label: "com.test.viewModelProviderQueue", qos: .userInitiated)

    // MARK: - Public APIs

    static func viewModels(for feeds: [Feed], completion: @escaping ViewModelProviderCompletionHandler) {
        viewModelProviderQueue.async {
            let viewModels = feeds.map({ FeedViewModel(feed: $0)})
            DispatchQueue.main.async {
                completion(viewModels)
            }
        }
    }
}
