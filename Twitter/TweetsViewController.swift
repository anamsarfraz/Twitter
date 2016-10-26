//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Unum Sarfraz on 10/26/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController {

    var tweets: [Tweet]?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        TwitterClient.sharedInstance.homeTimelineWithParams(params: nil) { (tweets, error) in
            self.tweets = tweets
            
            for tweet in self.tweets! {
             print ("text: \(tweet.text), created: \(tweet.createdAt)")
             }

            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onLogout(_ sender: AnyObject) {
        User.currentUser?.logout()
    }

}
