//
//  TweetCell.swift
//  Twitter
//
//  Created by Unum Sarfraz on 10/28/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit
import SwiftDate

class TweetCell: UITableViewCell {

    @IBOutlet weak var reactionImageView: UIImageView!
    @IBOutlet weak var reactionLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var tweet: Tweet! {
        didSet {
            setCellView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userProfileImageView.layer.cornerRadius = 3
        userProfileImageView.clipsToBounds = true

    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
    private func setCellView() {
        let createdAt = formatDate(date: tweet.createdAt!)
        if tweet.retweetedStatus != nil {
            reactionLabel.text = "\((tweet.user?.name)!) Retweeted"
            reactionImageView.image = UIImage(named: "RetweetDefault")
        } else {
            reactionLabel.text = ""
            reactionImageView.image = nil
        }

        let tweetData: Tweet = tweet.retweetedStatus != nil ? tweet.retweetedStatus! : tweet

        if let profileUrl = tweetData.user?.profileUrl {
            userProfileImageView.setImageWith(profileUrl)
        }
        usernameLabel.text = tweetData.user?.name
        screennameLabel.text = "@\((tweetData.user?.screenname)!) - \(createdAt)"
        tweetTextLabel.text = tweetData.text
        retweetCountLabel.text = "\(tweetData.retweetCount)"
        likeCountLabel.text = "\(tweetData.favoritesCount)"
        favoriteButton.isSelected = tweetData.isFavorited
        retweetButton.isSelected = tweetData.isRetweeted
        
        if favoriteButton.isSelected {
            favoriteButton.setImage(UIImage(named: "LikeOnAndHover"), for: UIControlState.selected)
        } else {
            favoriteButton.setImage(UIImage(named: "LikeDefault"), for: UIControlState.normal)
        }
        
        if retweetButton.isSelected {
            retweetButton.setImage(UIImage(named: "RetweetOnAndHover"), for: UIControlState.selected)
        } else {
            retweetButton.setImage(UIImage(named: "RetweetDefault"), for: UIControlState.normal)
        }        
    }
    
    private func updateRetweetCount() {
        retweetButton.isSelected = !retweetButton.isSelected
        if retweetButton.isSelected {
            tweet.retweetCount += 1
            print ("inside the update retweet method: \(retweetButton.isSelected)" )
            retweetButton.setImage(UIImage(named: "RetweetOnAndHover"), for: UIControlState.selected)
        } else {
            tweet.retweetCount -= 1
            retweetButton.setImage(UIImage(named: "RetweetDefault"), for: UIControlState.normal)
        }
        retweetCountLabel.text = "\(tweet.retweetCount)"
    }
    
    private func destroyTweet(tweetId: String) {
        // Destroy the retweet
        TwitterClient.sharedInstance.destroyTweet(tweetId: tweetId, params: nil) { (destroyResponse, error) in
            if destroyResponse != nil {
                self.tweet.isRetweeted = false
                /*let createdAt = self.tweet.createdAt
                self.tweet.updateTweetParams(dictionary: destroyResponse)
                self.tweet = self.tweet.retweetedStatus
                self.tweet.createdAt = createdAt
                self.tweet.retweetedStatus = nil
                self.tweet.isRetweeted = false
                self.setCellView()
                */
                print ("Successful tweet destroy")
            } else {
                print ("Got error destroying tweet, undoing the changes")
                self.updateRetweetCount()
            }
        }
    }
    
    private func unRetweet()  {
        if !tweet.isRetweeted {
            print ("Cannot unretweet a tweet that has not retweeted")
            updateRetweetCount()
            return
        }
        
        // Get the original tweet id
        let originalTweetId: String = (tweet.retweetedStatus != nil ? tweet.retweetedStatus?.tweetId : tweet.tweetId)!
        
        // Get the full retweet object containing retweet data. This will give the retweet id
        let parameters: [String : AnyObject] = [
            "id": originalTweetId as AnyObject,
            "include_my_retweet": "1" as AnyObject
        ]

        var retweetId: String?
        TwitterClient.sharedInstance.fullTweet(params: parameters as NSDictionary?) { (tweetResponse, error) in
            if let tweetResponse = tweetResponse {
                let userRetweet = tweetResponse["current_user_retweet"] as? NSDictionary
                if let userRetweet = userRetweet {
                    retweetId = userRetweet["id_str"] as? String
                    
                    // Destroy the tweet with the retweet id.
                    self.destroyTweet(tweetId: retweetId!)
                } else {
                    print ("Cannot find current_user_retweet_id")
                    self.updateRetweetCount()
                }
            } else {
                print ("Got error getting retweetId, undoing the changes")
            }
        }
    }
    
    private func updateFavoriteCount() {
        favoriteButton.isSelected = !favoriteButton.isSelected
        if favoriteButton.isSelected {
            tweet.favoritesCount += 1
            print ("inside the update method: \(favoriteButton.isSelected)" )
            favoriteButton.setImage(UIImage(named: "LikeOnAndHover"), for: UIControlState.selected)
        } else {
            tweet.favoritesCount -= 1
            favoriteButton.setImage(UIImage(named: "LikeDefault"), for: UIControlState.normal)
        }
        likeCountLabel.text = "\(tweet.favoritesCount)"
    }

    
    @IBAction func retweetButtonClicked(_ sender: AnyObject) {
        updateRetweetCount()
        print (tweet.tweetId)
        if retweetButton.isSelected {
            TwitterClient.sharedInstance.retweetTweetUpdate(tweetId: tweet.tweetId!,params: nil) { (retweetResponse, error) in
                if retweetResponse != nil {
                    self.tweet.isRetweeted = true
                    /*let createdAt = self.tweet.createdAt
                    self.tweet.updateTweetParams(dictionary: retweetResponse)
                    self.tweet = self.tweet.retweetedStatus
                    self.tweet.createdAt = createdAt
                    self.tweet.retweetedStatus = nil

                    self.setCellView()
                    */
                    print ("Successful retweet update")
                } else {
                    print ("Got error updating retweet tweet, undoing the changes")
                    self.updateRetweetCount()
                }
            }
        } else {
            unRetweet()
        }

    }
    
    @IBAction func favoriteButtonClicked(_ sender: AnyObject) {
        updateFavoriteCount()

        print (tweet.tweetId)
        let parameters: [String : AnyObject] = ["id": tweet.tweetId! as AnyObject]
        TwitterClient.sharedInstance.favoriteTweetUpdate(favorited: favoriteButton.isSelected, params: parameters as NSDictionary?) { (favoriteResponse, error) in
            if let favoriteResponse = favoriteResponse {
                self.tweet.updateTweetParams(dictionary: favoriteResponse)
                self.setCellView()
            } else {
                print ("Got error updating tweet, undoing the changes")
                self.updateFavoriteCount()
            }
        }
    }
    
    private func formatDate(date: Date) -> String {
        let now = Date()
        
        var createdAt = ""
        
        if date.isToday {
            let hoursDiff = now.hour - date.hour
            let minutesDiff = now.minute - date.minute
            let secondsDiff = now.second - date.second
            
            if  hoursDiff < 1 && minutesDiff < 1 {
                createdAt = "\(secondsDiff)s"
            } else if hoursDiff < 1 {
                createdAt = "\(minutesDiff)m"
            } else {
               createdAt = "\(hoursDiff)h"
            }
        } else if now.day - date.day < 7 {
            createdAt = "\(now.day - date.day)d"
        } else {
            createdAt = "\(date.month)/\(date.day)/\(date.year)"
        }
        return createdAt
    }

}
