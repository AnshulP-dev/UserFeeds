//
//  JsonParser.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 30/11/20.
//

import Foundation

class JsonParser {

    // MARK: - Public APIs

    static func parseJsonModels(models: [NSDictionary]) -> [Feed] {
        let decoder = JSONDecoder()
        return models.compactMap { (model) in
            guard let data = try? JSONSerialization.data(withJSONObject: model),
                  let feed = try? decoder.decode(Feed.self, from: data) else {
                assertionFailure("Parsing error occurred")
                return nil
            }
            return feed
        }
    }
}
