//
//  SettingsViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/12/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onSignOutButton(sender: AnyObject) {
        GPPSignIn.sharedInstance().signOut()
        NSLog("Signed Out")
//        openSignInModal(self)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onRevokeAccessButton(sender: AnyObject) {
        GPPSignIn.sharedInstance().disconnect()
        NSLog("Access Revoked")
//        openSignInModal(self)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
