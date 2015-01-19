//
//  SettingsViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/12/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var dietaryRestrictionsCell: UITableViewCell!
    @IBOutlet weak var checkForUpdatesCell: UITableViewCell!
    @IBOutlet weak var sendFeedbackCell: UITableViewCell!
    @IBOutlet weak var reportBugCell: UITableViewCell!
    @IBOutlet weak var signOutCell: UITableViewCell!
    
    private var mailComposeViewController : MFMailComposeViewController?
    
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
        } else if (selectedCell == checkForUpdatesCell) {
            checkForUpdates({ (needsUpdate: Bool) -> Void in
                if (!needsUpdate) {
                    var alert = UIAlertView(title: "Up to date!", message: nil, delegate: nil, cancelButtonTitle: "OK")
                    alert.show()
                }
            })
        } else if (selectedCell == sendFeedbackCell) {
            sendMail("Feedback")
        } else if (selectedCell == reportBugCell) {
            sendMail("Bug Report")
        }
    }
    
    private func sendMail(subject: String) {
        if (MFMailComposeViewController.canSendMail()) {
            mailComposeViewController = MFMailComposeViewController()
            mailComposeViewController?.mailComposeDelegate = self
            mailComposeViewController?.setSubject(subject)
            mailComposeViewController?.setToRecipients([kReportBugAddress])
            mailComposeViewController?.mailComposeDelegate = self
            self.presentViewController(mailComposeViewController!, animated: true, completion: nil)
        } else {
            var alert = UIAlertView(title: "This device cannot send mail.",
                message: "Please email \(kReportBugAddress) to send feedback or report bugs.",
                delegate: nil,
                cancelButtonTitle: "OK")
            alert.show()
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func onSignOutButton() {
        GPPSignIn.sharedInstance().signOut()
        GPPSignIn.sharedInstance().disconnect()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
