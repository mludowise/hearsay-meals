//
//  DinnerTonightViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/8/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

private let kCellIdentifier = "DinnerPeopleTableCell"
private let kCountdownRedColor = UIColor(red: 227.0 / 255, green: 26.0 / 255, blue: 28.0 / 255, alpha: 1)
private let kCountdownRedTime = NSTimeInterval(15.0 * 60) // 15 minutes

class DinnerTonightViewController: UITableViewController {
    
    @IBOutlet weak var notOrderedView: UIView!
    @IBOutlet weak var timeLeftLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var orderButtonActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var orderedView: UIView!
    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var cancelOrderActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var specialRequestEmptyView: UIView!
    @IBOutlet weak var specialRequestFilledView: UIView!
    @IBOutlet weak var specialRequestLabel: UILabel!
    
    @IBOutlet weak var numPeopleOrdered: UILabel!
    @IBOutlet weak var minimumPeopleMetLabel: UILabel!
    
    var dinnerOrdersTonight = [PFObject]()
    var userOrderIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPeopleEatingTonight(true)
        updateTimer()
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func updateTimer() {
        var timeToOrder = timeUntil(kTimeToOrderBy.hour, kTimeToOrderBy.minute, 0, kOfficeTimeZone)
        self.countdownLabel.text = NSString(format: "%u:%02u:%02u", Int(timeToOrder) / 3600, Int(timeToOrder) / 60 % 60, Int(timeToOrder) % 60)
        if (timeToOrder > kCountdownRedTime) {
            self.countdownLabel.textColor = UIColor.blackColor()
        } else {
            self.countdownLabel.textColor = kCountdownRedColor
        }
    }
    
    private func getPeopleEatingTonight(updateOrderedView: Bool) {
        var today = todayAtZero(nil)
        var tomorrow = tomorrowAtZero(nil)
        
        var query = PFQuery(className: kDinnerTableKey)
        query.whereKey(kDinnerOrderDateKey, greaterThanOrEqualTo: today)
        query.whereKey(kDinnerOrderDateKey, lessThan: tomorrow)
        query.orderByAscending(kCreatedAtKey)
        query.findObjectsInBackgroundWithBlock { (results: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("%@", error)
            } else {
                self.dinnerOrdersTonight = results as [PFObject]
                self.userOrderIndex = self.findUserOrder(self.dinnerOrdersTonight)
                
                if (updateOrderedView) {
                    self.displayDinnerOrdered(self.userOrderIndex != nil)
                }
                self.updateNumPeopleOrdered(self.dinnerOrdersTonight.count)
                self.updateSpecialRequest()
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dinnerOrdersTonight.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as DinnerPeopleTableCell
        cell.nameLabel.text = ""
        
        var query = PFUser.query()
        query.whereKey(kObjectId, equalTo: PFUser.currentUser().objectId)
        query.getFirstObjectInBackgroundWithBlock { (object: PFObject!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("%@", error)
            } else {
                var user = object as PFUser
                
                cell.nameLabel.text = user[kUserNameKey] as? String
                
                var imageUrl = NSURL(string: user[kUserPictureKey] as String)
                if (imageUrl == nil) {
                    return
                }
                var imageData = NSData(contentsOfURL: imageUrl!)
                if (imageData == nil) {
                    return
                }
                var image = UIImage(data: imageData!)

                cell.profileImage.image = image
            }
        }
        return cell
    }
    
    @IBAction func onOrderButton(sender: AnyObject) {
        orderButton.enabled = false
        orderButtonActivityIndicator.startAnimating()
        
        var userDinnerOrder = PFObject(className: kDinnerTableKey)
        userDinnerOrder[kDinnerOrderDateKey] = todayAtZero(nil)
        userDinnerOrder[kDinnerUserIdKey] = PFUser.currentUser().objectId
        
        // Save locally
        self.userOrderIndex = dinnerOrdersTonight.count
        self.dinnerOrdersTonight.append(userDinnerOrder)
        
        // Save remotely
        userDinnerOrder.saveInBackgroundWithBlock({ (Bool, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("%@", error)
            }
            
            // Update ordered view
            self.orderButtonActivityIndicator.stopAnimating()
            self.orderButton.enabled = true
            self.displayDinnerOrdered(true)
            
            // Update table
            self.tableView.beginUpdates()
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.userOrderIndex!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.tableView.endUpdates()
            self.updateNumPeopleOrdered(self.dinnerOrdersTonight.count)
        })
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        cancelOrderButton.hidden = true
        cancelOrderActivityIndicator.startAnimating()
        
        if (userOrderIndex != nil) {
            var userDinnerOrder = dinnerOrdersTonight[userOrderIndex!]
            
            // Delete locally
            self.dinnerOrdersTonight.removeAtIndex(self.userOrderIndex!)
            
            // Delete remotely
            userDinnerOrder.deleteInBackgroundWithBlock({ (Bool, error: NSError!) -> Void in
                if (error != nil) {
                    NSLog("%@", error)
                }
                
                // Update ordered view
                self.cancelOrderActivityIndicator.stopAnimating()
                self.cancelOrderButton.hidden = false
                self.displayDinnerOrdered(false)
                
                // Update table
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forItem: self.userOrderIndex!, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.endUpdates()
                self.updateNumPeopleOrdered(self.dinnerOrdersTonight.count)
                
                self.userOrderIndex = nil

            })
        }
    }
    
    @IBAction func editSpecialRequest(sender: AnyObject) {
        if (userOrderIndex == nil) {
            return
        }
        
        var userDinnerOrder = self.dinnerOrdersTonight[self.userOrderIndex!]
        
        var noteViewController = storyboard?.instantiateViewControllerWithIdentifier(kNoteViewControllerID) as NoteViewController
        noteViewController.titleBarText = "Dinner Request"
        noteViewController.initialText = userDinnerOrder[kDinnerSpecialRequestKey] as? String
        noteViewController.onDone = { (text: String) -> Void in
            
            userDinnerOrder[kDinnerSpecialRequestKey] = text
            userDinnerOrder.saveInBackground()
            
            self.specialRequestLabel.text = text
            self.specialRequestEmptyView.hidden = text != ""
        }
        presentViewController(noteViewController, animated: true, completion: nil)
    }
    
    @IBAction func onCalendarButton(sender: AnyObject) {
        
    }
    
    private func displayDinnerOrdered(dinnerOrdered: Bool) {
        UIView.animateWithDuration(0.1) { () -> Void in
            self.notOrderedView.alpha = dinnerOrdered ? 0 : 1
        }
    }
    
    private func updateNumPeopleOrdered(numberOrdered: Int) {
        if (numberOrdered == 1) {
            numPeopleOrdered.text = "1 Person Ordered"
        } else {
            numPeopleOrdered.text = "\(numberOrdered) People Ordered"
        }
        
        minimumPeopleMetLabel.hidden = numberOrdered >= kMinDinnerOrders
    }
    
    private func updateSpecialRequest() {
        var specialRequestText : String?
        if (userOrderIndex != nil) {
            specialRequestText = dinnerOrdersTonight[userOrderIndex!][kDinnerSpecialRequestKey] as? String
            specialRequestLabel.text = specialRequestText?
        }
        specialRequestEmptyView.hidden = specialRequestText != nil
    }
    
    private func findUserOrder(orders: [PFObject]) -> Int? {
        for (i, order) in enumerate(orders) {
            if (order[kDinnerUserIdKey] as String == PFUser.currentUser().objectId) {
                return i
            }
        }
        return nil
    }
}
