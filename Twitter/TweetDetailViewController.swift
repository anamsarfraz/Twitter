//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by Unum Sarfraz on 10/29/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit
import SwiftDate

class TweetDetailViewController: UIViewController {
    
    
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var retweetUserLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var retweetCountLabel: UILabel!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        // Customize navigation bar
        navigationItem.title = "Tweet"
        
        // Set tweet details
        setDetailView()
        
        // Set profile image border
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true

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
        favoriteCountLabel.text = "\(tweet.favoritesCount)"
    }
    

    private func setDetailView() {
        timestampLabel.text = formatDate(date: tweet.createdAt!)

        if tweet.retweetedStatus != nil {
            retweetUserLabel.text = "\((tweet.user?.name)!) Retweeted"
            retweetImageView.image = UIImage(named: "RetweetDefault")
        }

        let tweetData: Tweet = tweet.retweetedStatus != nil ? tweet.retweetedStatus! : tweet

        if let profileUrl = tweetData.user?.profileUrl {
            profileImageView.setImageWith(profileUrl)
        }
        usernameLabel.text = tweetData.user?.name
        screennameLabel.text = "@\((tweetData.user?.screenname)!)"
        tweetTextLabel.text = tweetData.text
        retweetCountLabel.text = "\(tweetData.retweetCount)"
        favoriteCountLabel.text = "\(tweetData.favoritesCount)"
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

    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: date)
        
    }
    
    @IBAction func onRetweetButton(_ sender: AnyObject) {
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
    
    @IBAction func onFavoriteButton(_ sender: AnyObject) {
        updateFavoriteCount()
        
        print (tweet.tweetId)
        let parameters: [String : AnyObject] = ["id": tweet.tweetId! as AnyObject]
        TwitterClient.sharedInstance.favoriteTweetUpdate(favorited: favoriteButton.isSelected, params: parameters as NSDictionary?) { (favoriteResponse, error) in
            if let favoriteResponse = favoriteResponse {
                self.tweet.updateTweetParams(dictionary: favoriteResponse)
                self.setDetailView()
            } else {
                print ("Got error updating tweet, undoing the changes")
                self.updateFavoriteCount()
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let tweetComposeVC = navigationController.topViewController as! TweetComposeViewController
        tweetComposeVC.user = User._currentUser
        tweetComposeVC.replyTo = tweet.tweetId
        
        tweetComposeVC.replyToScreenName = ""
        if let retweetedStatus = tweet.retweetedStatus {
            tweetComposeVC.replyToScreenName += "@\((retweetedStatus.user?.screenname)!) "
        }
        tweetComposeVC.replyToScreenName += "@\((tweet.user?.screenname)!) "
    }
    
}
