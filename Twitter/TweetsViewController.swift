//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Unum Sarfraz on 10/26/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetComposeViewControllerDelegate, UIScrollViewDelegate {
    
    var tweets: [Tweet]!
    var currTweets: [Tweet]!

    @IBOutlet weak var tableView: UITableView!
    
    var currOffSet = ""
    var currTotal = maxTweetLimit
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize empty arrays for tweets results
        tweets = [Tweet]()
        currTweets = [Tweet]()
        
        // Initialize tweets table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120

        // Set navigation bar colors
        navigationController?.navigationBar.barTintColor = twitterBlue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.isTranslucent = false

        // Create a UIRefreshControl instance and add it to tweets table view
        
        refreshControl.addTarget(self, action: #selector(refreshHomeTimeline), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets

        // Refresh the home timeline
        refreshHomeTimeline(refreshControl: refreshControl)
    }

    func refreshHomeTimeline(refreshControl: UIRefreshControl) {
        if (!isMoreDataLoading) {
            // Set the current offset to zero if there is no infinite scroll
            currOffSet = ""
        }

        var parameters: [String : AnyObject] = ["count": "20" as AnyObject]
        if currOffSet != "" {
            parameters["max_id"] = currOffSet as AnyObject
        }
        TwitterClient.sharedInstance.homeTimeline(params: parameters as NSDictionary) { (tweets, minId, error) in
            self.currTweets = tweets
                
            // Check if more data is loading, stop infinite scroll animation
            if (self.isMoreDataLoading) {
                self.loadingMoreView?.stopAnimating()
                self.isMoreDataLoading = false
                self.tweets.append(contentsOf: self.currTweets ?? [])
            } else {
                self.tweets = self.currTweets
            }

            if let minId = minId {
                self.currOffSet = minId
            }
            print ("Total tweets count after home timeline call: \(self.tweets.count)")
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tweetCell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        tweetCell.tweet = tweets?[indexPath.row]
        tweetCell.replyButton.tag = indexPath.row
        return tweetCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at:indexPath, animated: true)
    }

    func tweetComposeViewController(tweetComposeViewController: TweetComposeViewController, didCreateTweetOrReply data: NSDictionary) {
        let newTweet = Tweet(dictionary: data)
        if tweets == nil {
            tweets = [Tweet]()
        }
        tweets?.insert(newTweet, at: 0)
        tableView.reloadData()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                
                print ("Total tweets count in inifinite scroll: \(tweets.count)")
                if tweets.count < currTotal {
                    currOffSet = (tweets.last?.tweetId)!
                    loadingMoreView!.startAnimating()
                    refreshHomeTimeline(refreshControl: refreshControl)
                }
            }
        }
    }

    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.sharedInstance.logout()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController {
            let tweetComposeVC = navigationController.topViewController as! TweetComposeViewController
            tweetComposeVC.user = User._currentUser
            tweetComposeVC.delegate = self
            
            if let replyButton = sender as? UIButton {
                print ("sender is the reply Button")
                let tweet = (tweets?[replyButton.tag])!
                tweetComposeVC.replyTo = tweet.tweetId
                tweetComposeVC.replyToScreenName = ""
                if let retweetedStatus = tweet.retweetedStatus {
                    tweetComposeVC.replyToScreenName += "@\((retweetedStatus.user?.screenname)!) "
                }
                tweetComposeVC.replyToScreenName += "@\((tweet.user?.screenname)!) "

            }
            
        } else {
            let tweetCell = sender as! UITableViewCell
            let indexPath = tableView.indexPath(for: tweetCell)!
            
            let detailViewController = segue.destination as! TweetDetailViewController
            detailViewController.tweet = tweets?[indexPath.row]
        }
        
    }
}
