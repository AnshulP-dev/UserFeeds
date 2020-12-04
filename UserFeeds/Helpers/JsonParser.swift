//
//  JsonParser.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 30/11/20.
//

import Foundation

/**
 Helper class responsible for parsing JSON data into Swift models
 */
class JsonParser {

    // MARK: - Public APIs

    /**
     This method takes json data as input and parse that data into Swift `Feed` models
     - parameter models: Json dictionary that needs to be parsed
     - returns: Array of `Feed` models
     */
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
