//
//  Feed.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 29/11/20.
//

enum FeedType: Equatable {
    case text(text: String?)
    case image(imageURLString: String?)
    case other(text: String?)
}

class Feed: Decodable {
    let id: String
    let type: String
    let data: String?
    let date: String?
}

extension Feed {

    var feedType: FeedType {
        if type == "text" {
            return .text(text: data?.trimmingCharacters(in: .whitespacesAndNewlines))
        } else if type == "image" {
            return .image(imageURLString: data)
        } else {
            return .other(text: data?.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}
