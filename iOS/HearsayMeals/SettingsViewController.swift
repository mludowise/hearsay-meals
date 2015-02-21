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
    @IBOutlet weak var preferencesLabel: UILabel!
    @IBOutlet weak var preferencesIconsView: UIView!
    @IBOutlet weak var ellipsesLabel: UILabel!
    
    @IBOutlet weak var checkForUpdatesCell: UITableViewCell!
    @IBOutlet weak var sendFeedbackCell: UITableViewCell!
    @IBOutlet weak var reportBugCell: UITableViewCell!
    
    @IBOutlet weak var signOutCell: UITableViewCell!
    
    var preferenceIconViews : [UIImageView] = []
    private var mailComposeViewController : MFMailComposeViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = PFUser.currentUser().name
        emailLabel.text = PFUser.currentUser().email
        profileImageView.image = loadImageFromURL(PFUser.currentUser().pictureURL)
    }
    
    override func viewDidAppear(animated: Bool) {
        updatePreferenceIcons()
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
    
    func updatePreferenceIcons() {
        // Remove all icons from previously
        for iconView in preferenceIconViews {
            iconView.removeFromSuperview()
        }
        preferenceIconViews = []
        ellipsesLabel.hidden = true
        
        var preferences = PFUser.currentUser().preferences
        var iconViews = getPreferenceIcons(preferences)
        
        // Calculate how many icons can be displayed
        var totalIconWidth = CGFloat(0)
        for (index, iconView) in enumerate(iconViews) {
            if (totalIconWidth + iconView.frame.width > preferencesIconsView.frame.width) { // Can't fit anymore icons
                if (totalIconWidth + ellipsesLabel.frame.width > preferencesIconsView.frame.width) { // Can't fit ellipses
                    println("too too many")
                    preferenceIconViews.removeLast()
                    totalIconWidth -= (iconViews[index-1].frame.width + 5)
                }
                break
            }
            totalIconWidth += iconView.frame.width + 5
            preferenceIconViews.append(iconView)
        }
        totalIconWidth -= 5
        
        // Add icons
        var position = preferencesIconsView.frame.size.width
        if (preferenceIconViews.count < iconViews.count) {
            ellipsesLabel.hidden = false
            position = ellipsesLabel.frame.origin.x - 5
        }
        for iconView in reverse(preferenceIconViews) {
            preferencesIconsView.addSubview(iconView)
            position = position - iconView.frame.width
            iconView.frame.origin.x = position
            position -= 5
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

private func getPreferenceIcons(ids: [Int]) -> [UIImageView] {
    var sortedPreferences = ids
    sortedPreferences.sort { (a: Int, b: Int) -> Bool in
        var a2 = a==3 ? 4 : a==4 ? 3 : a
        var b2 = b==3 ? 4 : b==4 ? 3 : b
        return b2 > a2
    }

    var iconViews : [UIImageView] = []
    for id in sortedPreferences {
        let iconView = getPreferenceIcon(id)
        if (iconView != nil) {
            iconViews.append(iconView!)
        }
    }
    return iconViews
}

private func getPreferenceIcon(id: Int) -> UIImageView? {
    var iconView = UIImageView()
    iconView.frame.size = CGSize(width: 24, height: 24)
    iconView.contentMode = UIViewContentMode.Left
    
    switch(id) {
    case 0:
        iconView.image = UIImage(named: "omnivore")
    case 1:
        iconView.image = UIImage(named: "vegetarian")
    case 2:
        iconView.image = UIImage(named: "vegan")
    case 3:
        iconView.image = UIImage(named: "no_gluten")
        iconView.frame.size.width = 36
    case 4:
        iconView.image = UIImage(named: "pescetarian")
    case 5:
        iconView.image = UIImage(named: "no_nuts")
        iconView.frame.size.width = 32
    case 6:
        iconView.image = UIImage(named: "no_soy")
        iconView.frame.size.width = 36
    case 7:
        iconView.image = UIImage(named: "no_eggs")
        iconView.frame.size.width = 33
    case 8:
        iconView.image = UIImage(named: "no_dairy")
        iconView.frame.size.width = 33
    case 9:
        iconView.image = UIImage(named: "no_shellfish")
        iconView.frame.size.width = 36
    case 10:
        iconView.image = UIImage(named: "no_fish")
        iconView.frame.size.width = 36
    case 11:
        iconView.image = UIImage(named: "no_pork")
        iconView.frame.size.width = 36
    case 12:
        iconView.image = UIImage(named: "no_beef")
        iconView.frame.size.width = 32
    case 13:
        iconView.image = UIImage(named: "no_lamb")
        iconView.frame.size.width = 33
    case 14:
        iconView.image = UIImage(named: "no_poultry")
        iconView.frame.size.width = 33
    case 15:
        iconView.image = UIImage(named: "no_garlic")
        iconView.frame.size.width = 36
    default:
        return nil
    }
    
    return iconView
}
