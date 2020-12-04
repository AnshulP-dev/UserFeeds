//
//  Feed.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 29/11/20.
//

import RealmSwift

/**
 Its a model class representing the server model and can be saved in Realm database as well
 */
class Feed: Object, Decodable {
    @objc dynamic var id: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var data: String?
    @objc dynamic var date: String?
}

/**
 It represents the type of data, user has shared in form of Feed (text, image, url etc)
 */
enum FeedType: Equatable {
    case text(text: String?)
    case image(imageURLString: String?)
    case other(text: String?)
}

struct FeedTypeConstant {
    static let text = "text"
    static let image = "image"
}

extension Feed {
    var feedType: FeedType {
        if type == FeedTypeConstant.text {
            return .text(text: data?.trimmingCharacters(in: .whitespacesAndNewlines))
        } else if type == FeedTypeConstant.image {
            return .image(imageURLString: data)
        } else {
            return .other(text: data?.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
}
