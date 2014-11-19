//
//  SettingsViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/12/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var dietaryRestrictionsCell: UITableViewCell!
    @IBOutlet weak var signOutCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = PFUser.currentUser()[kUserNameKey] as? String
        emailLabel.text = PFUser.currentUser().email
        profileImageView.image = loadImageFromURL(PFUser.currentUser()[kUserPictureKey] as String)
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        
        if (selectedCell == signOutCell) {
            onSignOutButton()
        }
    }
    
    func onSignOutButton() {
        GPPSignIn.sharedInstance().signOut()
        GPPSignIn.sharedInstance().disconnect()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
