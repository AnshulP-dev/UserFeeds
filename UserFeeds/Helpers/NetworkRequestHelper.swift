//
//  NetworkRequestHelper.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 29/11/20.
//

import Alamofire

/**
 Helper class responsible for encapsulating network request logic
 */
class NetworkRequestHelper {

    typealias UserFeedsCompletionHandler = ([Feed]?, Error?) -> Void

    // MARK: - Constants

    private static let feedsURLString = "https://raw.githubusercontent.com/AxxessTech/Mobile-Projects/master/challenge.json"
    private static let networkQueue = DispatchQueue(label: "com.test.networkQueue", qos: .userInitiated)

    // MARK: - Public APIs

    /**
     It fetches User Feeds, does the parsing operation to convert network data into `Feed` models and calls the completion handler on main thread.
     - parameter completion: Closure that will be called on main thread with the `Feed` models and `Error` (if there's any)
     */
    static func fetchUserFeeds(completion: @escaping UserFeedsCompletionHandler) {
        // NOTE: To always load the data from network, can set `request.cachePolicy = .reloadIgnoringLocalCacheData`
        // in `requestModifier` block
        AF.request(feedsURLString)
        .validate()
        .responseJSON(queue: networkQueue) { (response) in
            switch response.result {
            case .success(let value):

                if let models = value as? [NSDictionary] {
                    let feeds = JsonParser.parseJsonModels(models: models)
                    DispatchQueue.main.async {
                        completion(feeds, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        // TODO: Create parsing error and send it to the completion handler
                        completion(nil, nil)
                    }
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
}
