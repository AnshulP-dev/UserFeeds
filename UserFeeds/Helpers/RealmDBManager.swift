//
//  RealmDBManager.swift
//  UserFeeds
//
//  Created by Anshul Parashar on 04/12/20.
//

import RealmSwift

/**
 Helper class responsible for encapsulating database logic
 */
class RealmDBManager {

    private static let realmDBQueue = DispatchQueue(label: "com.test.realmDBQueue")

    // MARK: - Internal methods

    /**
     This method deletes the existing feeds and saves new feeds in Realm database
     - parameter newFeeds: New feed models that needs to be saved in database
     */
    static func deleteOldFeedsAndSave(newFeeds: [Feed]) {
        realmDBQueue.async {
            do {
                let realm = try Realm()
                try realm.write {
                    realm.delete(realm.objects(Feed.self))
                    realm.add(newFeeds)
                }
            } catch let error {
                // TODO: Handle error
                print("ERROR: Realm Save operation error: \(error.localizedDescription)")
            }
        }
    }

    /**
     This method fetch the existing feed models from Realm database and returns the thread safe references of those Feed models
     - returns: Returns array of thread safe feed-model references
     */
    static func existingFeeds() -> [ThreadSafeReference<Feed>] {
        do {
            let realm = try Realm()
            return realm.objects(Feed.self).map { ThreadSafeReference(to: $0) }
        } catch let error {
            // TODO: Handle error
            print("ERROR: Realm fetch operation error: \(error.localizedDescription)")
        }
        return []
    }
}
