//
//  ViewController.swift
//  Twitter
//
//  Created by Unum Sarfraz on 10/25/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginButton(_ sender: AnyObject) {
        
        let client = TwitterClient.sharedInstance
        client.login(success: { () -> () in
            self.performSegue(withIdentifier: "loginSegue", sender: self)
        }) { (error: Error) in
            print ("Error: \(error.localizedDescription)")
        }
    }
}

