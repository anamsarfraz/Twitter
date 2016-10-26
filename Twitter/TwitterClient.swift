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

class TwitterClient: BDBOAuth1RequestOperationManager {

    var loginCompletion: ((_ user: User?, _ error: Error?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance = TwitterClient(
                baseURL: twitterBaseURL as URL!,
                consumerKey: twitterConsumerKey,
                consumerSecret: twitterConsumerSecret
            )
        }
        return Static.instance!
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: @escaping (_ tweets: [Tweet]?, _ error: Error?) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: params, success: { (operation: AFHTTPRequestOperation, response: Any) in
            //print ("Home timeline: \(response)")
            let tweets = Tweet.tweetsWithArray(array: response as! [NSDictionary])
            completion(tweets, nil)
            /*for tweet in tweets {
             print ("text: \(tweet.text), created: \(tweet.createdAt)")
             }*/
        }) { (operation: AFHTTPRequestOperation?, error: Error) in
            print ("Error getting home timeline")
            completion(nil, error)
        }
    }
    
    func loginWithCompletion(completion: @escaping (_ user: User?, _ error: Error?) -> ()) {
        loginCompletion = completion
        
        // Fetch request token & redirect to authorization page
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        TwitterClient.sharedInstance.fetchRequestToken(withPath: "oauth/request_token",
            method: "GET", callbackURL: NSURL(string:"cptwitterdemo://oauth") as URL!,
            scope: nil, success: {(requestToken: BDBOAuth1Credential?) -> Void in
            print ("Got the request token")
            
            let authURL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\((requestToken?.token!)!)")
            UIApplication.shared.open(authURL!, options: [:], completionHandler: {(isSuccess: Bool?) in
                print ("Successful redirect")
            })
        }) {(error: Error?) -> Void in
            print ("Failed to get the request token")
            self.loginCompletion?(nil, error)
        }

    }
    
    func openURL(url: URL) {
        fetchAccessToken(withPath: "oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential?) in
            print("Got the access token")

            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            TwitterClient.sharedInstance.get("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation, response: Any) in
                //print ("user: \(response)")
                let user = User(dictionary: response as! NSDictionary)
                User.currentUser = user
                //print ("user: \(user.name)")
                self.loginCompletion?(user, nil)
                }, failure: { (operation: AFHTTPRequestOperation?, error: Error) in
                    print ("Error getting current user")
            })
            

            /*TwitterClient.sharedInstance.get("1.1/statuses/home_timeline.json", parameters: nil, success: { (operation: AFHTTPRequestOperation, response: Any) in
                //print ("Home timeline: \(response)")
                let tweets = Tweet.tweetsWithArray(array: response as! [NSDictionary])
                
                /*for tweet in tweets {
                 print ("text: \(tweet.text), created: \(tweet.createdAt)")
                 }*/
            }) { (operation: AFHTTPRequestOperation?, error: Error) in
                //print ("Error getting home timeline")
            }
 */
        }) { (error: Error?) in
            print ("Failed to get the access token")
            self.loginCompletion?(nil, error)
            
        }
        

    }
}
