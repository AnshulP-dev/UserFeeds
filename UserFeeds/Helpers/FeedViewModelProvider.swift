//
//  FeedViewModelProvider.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 29/11/20.
//

import RealmSwift

/**
 Helper class that converts `Feed` models into `FeedViewModels`
 */
class FeedViewModelProvider {

    typealias ViewModelProviderCompletionHandler = ([FeedViewModel]) -> Void

    // MARK: - Constants

    /// Create background queue with high priority because once network data is available, its processing should be prioritized to make it available for end user display
    private static let viewModelProviderQueue = DispatchQueue(label: "com.test.viewModelProviderQueue", qos: .userInitiated)

    // MARK: - Public APIs

    /**
     Its a helper method that takes feed models and converts that into FeedViewModels.
     It creates view-models on a background queue and once the view models are created, it calls the completion handler on main queue with the created view models.

     - parameter feeds: Feed models using which view-models will be created
     - parameter completion: Closure that will be called on main thread with the created view models
     */
    static func viewModels(for feeds: [Feed], completion: @escaping ViewModelProviderCompletionHandler) {
        viewModelProviderQueue.async {
            let viewModels = feeds.map({ FeedViewModel(feed: $0) })
            DispatchQueue.main.async {
                completion(viewModels)
            }
        }
    }

    /**
     Its a helper method that takes thread-safe feed model references and converts that into FeedViewModels.
     This method is usefull when models are fetched from realm DB and when those models are used in cross thread environment.
     It creates view-models on a background queue and once the view models are created, it calls the completion handler on main queue with the created view models.

     - parameter threadSafeFeedReferences: feed model references using which view-models will be created
     - parameter completion: Closure that will be called on main thread with the created view models
     */
    static func viewModels(for threadSafeFeedReferences: [ThreadSafeReference<Feed>], completion: @escaping ViewModelProviderCompletionHandler) {
        viewModelProviderQueue.async {
            let viewModels: [FeedViewModel]
            if let realm = try? Realm() {
                viewModels = threadSafeFeedReferences.compactMap { (threadSafeFeedReference) -> FeedViewModel? in
                    guard let feed = realm.resolve(threadSafeFeedReference) else { return nil }
                    return FeedViewModel(feed: feed)
                }
            } else {
                viewModels = []
            }

            DispatchQueue.main.async {
                completion(viewModels)
            }
        }
    }
}
