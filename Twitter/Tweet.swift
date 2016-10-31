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
    var tweetId: String?
    var text: String?
    var retweetCount: Int = 0
    var favoritesCount: Int = 0
    var createdAt: Date?
    var retweetedStatus: Tweet?
    var isRetweeted: Bool = false
    var isFavorited: Bool = false
    
    init(dictionary: NSDictionary) {
        super.init()
        updateTweetParams(dictionary: dictionary)
    }

    func updateTweetParams(dictionary: NSDictionary) {
        print ("updating favorite response")
        
        user = User(dictionary: dictionary[tweetUser] as! NSDictionary)
        tweetId = dictionary[ID] as? String
        text = dictionary[tweetText] as? String
        retweetCount = (dictionary[tweetRetweetCount] as? Int) ?? 0
        isRetweeted = (dictionary[retweeted] as? Int) ?? 0 == 1
        favoritesCount = (dictionary[tweetFavoritesCount] as? Int) ?? 0
        isFavorited = (dictionary[favorited] as? Int) ?? 0 == 1

        let createdAtString = dictionary[tweetCreatedAt] as? String
        
        if let createdAtString = createdAtString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            createdAt = formatter.date(from: createdAtString)
        }
        
        let retweet = dictionary[RETWEETED_STATUS] as? NSDictionary
        if retweet != nil {
            retweetedStatus = Tweet(dictionary: retweet!)
        }

    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> ([Tweet], String) {
        var tweets = [Tweet]()
        var minId: Int = Int.max
        for dictionary in array {
            print (dictionary)
            let tweet = Tweet(dictionary: dictionary)
            if minId > Int(tweet.tweetId!)! {
                minId = Int(tweet.tweetId!)!
            }
            
            tweets.append(tweet)
            
            
            
            
        }
        return (tweets, "\((minId-1))")
    }
}
