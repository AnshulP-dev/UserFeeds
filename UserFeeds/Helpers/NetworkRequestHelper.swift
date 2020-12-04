//
//  NetworkRequestHelper.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 29/11/20.
//

import Alamofire

class NetworkRequestHelper {

    typealias UserFeedsCompletionHandler = ([Feed]?, Error?) -> Void

    // MARK: - Constants

    private static let feedsURLString = "https://raw.githubusercontent.com/AxxessTech/Mobile-Projects/master/challenge.json"
    private static let networkQueue = DispatchQueue(label: "com.test.networkQueue", qos: .userInitiated)

    // MARK: - Public APIs

    static func fetchUserFeeds(completion: @escaping UserFeedsCompletionHandler) {
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
