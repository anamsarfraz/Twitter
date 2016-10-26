//
//  ViewController.swift
//  Twitter
//
//  Created by Unum Sarfraz on 10/25/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onLogin(_ sender: AnyObject) {
        
        TwitterClient.sharedInstance.loginWithCompletion() {
            (user: User?, erro: Error?) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: self)
            } else {
                // handle login error
            }
        }
        
    }

}

