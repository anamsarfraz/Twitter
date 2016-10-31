//
//  TwitterClient.swift
//  Twitter
//
//  Created by Unum Sarfraz on 10/25/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

import AFNetworking
import BDBOAuth1Manager

let twitterConsumerKey = "4MYbq0IOFXCJg4lHMlcu23nfO"
let twitterConsumerSecret = "dFIDL9hl35cqdt7WeDANX45h7ythP0X9MIcHVYoEdrvBxuYGMS"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: twitterBaseURL as URL!, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)!
    
    var loginSuccess: (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    
    func homeTimeline(params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ minId: String?, _ error: Error?) -> ()) {
        
        get("1.1/statuses/home_timeline.json", parameters: params, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
            //print ("Home timeline: \(response)")
            let (tweets, minId) = Tweet.tweetsWithArray(array: response as! [NSDictionary])
            completion(tweets, minId, nil)
            }, failure: { (operation: URLSessionDataTask?, error: Error) in
                print ("Error getting home timeline: \(error.localizedDescription)")
                completion(nil, nil, error)
        })
    }
    
    func fullTweet(params: NSDictionary?, completion: @escaping (_ response: NSDictionary?, _ error: Error?) -> ()) {
        
        get("1.1/statuses/show.json", parameters: params, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
            print ("Successfully received the full tweet: \(response)")
            completion(response as! NSDictionary?, nil)
            }, failure: { (operation: URLSessionDataTask?, error: Error) in
                print ("Error getting full tweet: \(error.localizedDescription)")
                completion(nil, error)
        })
    }

    func favoriteTweetUpdate(favorited: Bool, params: NSDictionary?, completion: @escaping (_ response: NSDictionary?, _ error: Error?) -> ()) {
        
        let createOrDestroy = favorited ? "create" : "destroy"
        post("1.1/favorites/\(createOrDestroy).json", parameters: params, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
            
            //print ("Favorites count successful: \(response as! [NSDictionary])")
            print ("Successful favorites count update")
            print ("Favorites count successful: \(response)")
            completion(response as! NSDictionary?, nil)
            }, failure: { (operation: URLSessionDataTask?, error: Error) in
                print ("Error getting favorites count: \(error.localizedDescription)")
                completion(nil, error)
        })
    }

    func retweetTweetUpdate(tweetId: String, params: NSDictionary?, completion: @escaping (_ response: NSDictionary?, _ error: Error?) -> ()) {
        
        post("1.1/statuses/retweet/\(tweetId).json", parameters: params, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
            print ("Successful retweet count update")
            print ("Retweet count successful: \(response)")
            completion(response as! NSDictionary?, nil)
            }, failure: { (operation: URLSessionDataTask?, error: Error) in
                print ("Error updating retweet count: \(error.localizedDescription)")
                completion(nil, error)
        })
    }
    
    func createTweetOrReply(params: NSDictionary?, completion: @escaping (_ response: NSDictionary?, _ error: Error?) -> ()) {
        
        post("1.1/statuses/update.json", parameters: params, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
            
            print ("Successful tweet post")
            completion(response as! NSDictionary?, nil)
            }, failure: { (operation: URLSessionDataTask?, error: Error) in
                print ("error posting tweet: \(error.localizedDescription)")
                completion(nil, error)
        })
    }

    func destroyTweet(tweetId: String, params: NSDictionary?, completion: @escaping (_ response: NSDictionary?, _ error: Error?) -> ()) {
        
        post("1.1/statuses/destroy/\(tweetId).json", parameters: params, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
            
            print ("Successful tweet deletion response: \(response)")
            completion(response as! NSDictionary?, nil)
            }, failure: { (operation: URLSessionDataTask?, error: Error) in
                print ("Error deleting tweet: \(error.localizedDescription)")
                completion(nil, error)
        })
    }
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure
        
        // Fetch request token & redirect to authorization page
        TwitterClient.sharedInstance.deauthorize()
        fetchRequestToken(withPath: "oauth/request_token",
            method: "GET", callbackURL: NSURL(string:"cptwitterdemo://oauth") as URL!,
            scope: nil, success: {(requestToken: BDBOAuth1Credential?) -> Void in
            print ("Got the request token")
                                                        
            let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\((requestToken?.token!)!)")
            UIApplication.shared.open(authURL!, options: [:], completionHandler: {(isSuccess: Bool?) in
                print ("Successful redirect")
            })
        }) {(error: Error?) -> Void in
            print ("Failed to get the request token")
            self.loginFailure?(error!)
        }
        
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: userDidLogoutNotification), object: nil)

    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
            print("Got the access token")
            
            //TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            self.currentAccount(success: { (user: User) in
                User.currentUser = user
                self.loginSuccess?()
                }, failure: { (error: Error) in
                    self.loginFailure?(error)
            })
            
        }) { (error: Error?) in
            print ("Failed to get the access token")
            self.loginFailure?(error!)
        }
        
    }
    
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (operation: URLSessionDataTask, response: Any?) in
            let user = User(dictionary: response as! NSDictionary)
            success(user)
            }, failure: { (operation: URLSessionDataTask?, error: Error) in
                print ("Error getting current user")
                failure(error)
                
        })
    }
}
