//
//  User.swift
//  Twitter
//
//  Created by Unum Sarfraz on 10/26/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCuurentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var name: String?
    var screenname: String?
    var profileImageUrl: String?
    var tagline: String?
    var dictionary: NSDictionary
    
    init(dictionary: NSDictionary) {
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        tagline = dictionary["description"] as? String
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: userDidLogoutNotification), object: nil)
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let data = UserDefaults.standard.object(forKey: currentUserKey) as? Data
                var dictionary: NSDictionary?
                if data != nil {
                    do {
                        try dictionary = JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        _currentUser = User(dictionary: dictionary!)
                        
                    } catch {
                        dictionary = nil
                    }
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            var data: Data?
            if _currentUser != nil {
                do {
                    try data = JSONSerialization.data(withJSONObject: user!.dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
                } catch {
                    data = nil

                }
                UserDefaults.standard.set(data, forKey: currentUserKey)
            } else {
                UserDefaults.standard.set(nil, forKey: currentUserKey)
            }
            UserDefaults.standard.synchronize()

        }
        
    }
}
