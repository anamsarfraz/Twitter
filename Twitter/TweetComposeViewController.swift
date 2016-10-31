//
//  TweetComposeViewController.swift
//  Twitter
//
//  Created by Unum Sarfraz on 10/30/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

@objc protocol TweetComposeViewControllerDelegate {
    @objc optional func tweetComposeViewController(tweetComposeViewController: TweetComposeViewController, didCreateTweetOrReply data: NSDictionary)
}


class TweetComposeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var tweetButton: UIBarButtonItem!
    @IBOutlet weak var charCountLabel: UILabel!
    weak var delegate: TweetComposeViewControllerDelegate?

    var user: User!
    var replyTo: String?
    var replyToScreenName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigation bar colors
        navigationController?.navigationBar.barTintColor = twitterBlue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.navigationBar.isTranslucent = false
        
        setUserAttributes()
        
        // Set profile image border
        profileImageView.layer.cornerRadius = 3
        profileImageView.clipsToBounds = true
        
        // Set text view as the first responder
        tweetTextView.becomeFirstResponder()
        tweetTextView.delegate = self
        setTextViewAttributes()
        
        // Check if its a reply
        if replyTo != nil {
            tweetTextView.text = replyToScreenName
            tweetTextView.textColor = UIColor.black
            let numCharLeft = 140 - tweetTextView.text.characters.count
            manageCharCount(numCharLeft: numCharLeft)
        }
    }
    
    private func setUserAttributes() {
        if let profileUrl = user?.profileUrl {
            profileImageView.setImageWith(profileUrl)
        }
        usernameLabel.text = user.name
        screennameLabel.text = "\((user.screenname)!)"
    }
    
    private func setTextViewAttributes() {
        tweetTextView.text = placeHolderTweetText
        tweetTextView.textColor = UIColor.lightGray
        tweetTextView.selectedTextRange = tweetTextView.textRange(from: tweetTextView.beginningOfDocument, to: tweetTextView.beginningOfDocument)

    }
    
    private func manageCharCount(numCharLeft: Int) {
        // Update count label and enable/ disable tweet button with char count
        charCountLabel.text = "\(numCharLeft)"
        if numCharLeft < 20 {
            charCountLabel.textColor = UIColor.red
        } else {
            charCountLabel.textColor = UIColor.white
        }
        
        if numCharLeft < 0 || numCharLeft >= 140 {
            tweetButton.isEnabled = false
        } else {
            tweetButton.isEnabled = true
        }
    }
    /*func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) o{
        if tweetTextView.text.isEmpty {
            tweetTextView.text = "What's happening?"
            tweetTextView.textColor = UIColor.lightGray
        }
    }*/
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if tweetTextView.textColor == UIColor.lightGray {
                tweetTextView.selectedTextRange = tweetTextView.textRange(from: tweetTextView.beginningOfDocument, to: tweetTextView.beginningOfDocument)
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        print ("Coming in should change text with replacement : \(text)")
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText = textView.text as NSString?
        
        let updatedText = currentText?.replacingCharacters(in: range, with: text)
        var numCharsLeft = 140 - (updatedText?.characters.count)!
        
        print ("current text: \(currentText) , updatedtext: \(updatedText)")
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        
        if (updatedText?.isEmpty)! {
            setTextViewAttributes()
            numCharsLeft = 140 - text.characters.count
            manageCharCount(numCharLeft: numCharsLeft)
            return false
        } else if textView.textColor == UIColor.lightGray {
            // Else if the text view's placeholder is showing and the
            // length of the replacement string is greater than 0, clear
            // the text view and set its color to black to prepare for
            // the user's entry
            if !text.isEmpty {
                textView.text = nil
                textView.textColor = UIColor.black
            }
            numCharsLeft = 140 - text.characters.count
        }
        
        manageCharCount(numCharLeft: numCharsLeft)
        return true
    }

    
    @IBAction func onTweetButton(_ sender: AnyObject) {
        
        if tweetButton.isEnabled {
            var parameters: [String : AnyObject] = ["status": tweetTextView.text as AnyObject]
            if let replyTo = replyTo {
                parameters["in_reply_to_status_id"] = replyTo as AnyObject
            }
            TwitterClient.sharedInstance.createTweetOrReply(params: parameters as NSDictionary?) { (tweetResponse, error) in
                if let tweetResponse = tweetResponse {
                    print ("successful tweet response: \(tweetResponse)")
                    self.dismiss(animated: true, completion: nil)
                    self.delegate?.tweetComposeViewController?(tweetComposeViewController: self, didCreateTweetOrReply: tweetResponse)
                } else {
                    print ("Got error creating tweet or reply, undoing the changes")
                    self.dismiss(animated: true, completion: nil)
                }
            }

        } else {
            print ("tweet button not enabled")
        }
        
    }
    
    @IBAction func onCancelButton(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
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

}
