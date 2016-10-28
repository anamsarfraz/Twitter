//
//  Tweet.swift
//  Twitter
//
//  Created by Unum Sarfraz on 10/26/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var user: User?
    var text: String?
    var reweetCount: Int = 0
    var favoritesCount: Int = 0
    var createdAt: Date?
    
    
    init(dictionary: NSDictionary) {
        user = User(dictionary: dictionary[tweetUser] as! NSDictionary)
        text = dictionary[tweetText] as? String
        reweetCount = (dictionary[tweetRetweetCount] as? Int) ?? 0
        favoritesCount = (dictionary[tweetFavoritesCount] as? Int) ?? 0
        
        let createdAtString = dictionary[tweetCreatedAt] as? String
        
        if let createdAtString = createdAtString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            createdAt = formatter.date(from: createdAtString)
        }
        
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        for dictionary in array {
            tweets.append(Tweet(dictionary: dictionary))
        }
        return tweets
    }
}
