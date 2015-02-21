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
    
    var dinnerConfig : DinnerConfig?
    
    var dinnerOrdersTonight = [DinnerOrder]()
    var userOrderIndex : Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getPeopleEatingTonight(true, nil)
        getDinnerConfig()
    }
    
    private func getDinnerConfig() {
        PFCloud.callFunctionInBackground("dinnerGetConfigs", withParameters: CloudDataUtil.empty()) { (result: AnyObject!, error: NSError!) -> Void in
            if (error != nil || result == nil) {
                NSLog("\(error)")
                self.timeLeftLabel.hidden = true
                return
            }
            
            self.dinnerConfig = DinnerConfig(data: result as NSDictionary)
            NSLog("Dinner Config: \(self.dinnerConfig)")
            
            self.updateTimer()
            NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTimer", userInfo: nil, repeats: true)
        }
    }
    
    private func getPeopleEatingTonight(updateOrderedView: Bool, completion: (() -> Void)?) {
        var dinnerRequest = DinnerRequest(date: NSDate())
        
        PFCloud.callFunctionInBackground("dinnerGetOrders", withParameters: dinnerRequest.data) { (result: AnyObject!, error: NSError!) -> Void in
            if (error != nil || result == nil) {
                NSLog("\(error)")
                return
            }
            
            self.dinnerOrdersTonight = DinnerOrder.arrayFromData(result as [NSDictionary]?)
            NSLog("Fetched \(self.dinnerOrdersTonight.count) Dinner Orders")
            
            self.userOrderIndex = self.findUserOrder(self.dinnerOrdersTonight)
            
            if (updateOrderedView) {
                self.displayDinnerOrdered(self.userOrderIndex != nil)
            }
            self.updateNumPeopleOrdered(self.dinnerOrdersTonight.count)
            self.updateSpecialRequest()
            self.tableView.reloadData()
            completion?()
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
        
        let order = dinnerOrdersTonight[indexPath.row]
        cell.update(order.userInfo.name, pictureURL: order.userInfo.pictureURL, specialRequest: order.specialRequest)
        return cell
    }
    
    @IBAction func onRefreshTable(sender: UIRefreshControl) {
        getPeopleEatingTonight(true, completion: { () -> Void in
            sender.endRefreshing()
        })
    }
    
    @IBAction func onOrderButton(sender: AnyObject) {
        orderButton.enabled = false
        orderButtonActivityIndicator.startAnimating()
        
        var dinnerRequest = DinnerRequest(date: NSDate())
        
        PFCloud.callFunctionInBackground("dinnerMakeOrder", withParameters: dinnerRequest.data) { (result: AnyObject!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("\(error)")
                return
            }
            
            // Update ordered view
            self.orderButtonActivityIndicator.stopAnimating()
            self.orderButton.enabled = true
            self.updateSpecialRequest()
            self.displayDinnerOrdered(true)

            // Update table
            self.getPeopleEatingTonight(true, completion: nil)
        }
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        cancelOrderButton.hidden = true
        cancelOrderActivityIndicator.startAnimating()

        var dinnerRequest = DinnerRequest(date: NSDate())
        
        PFCloud.callFunctionInBackground("dinnerCancelOrder", withParameters: dinnerRequest.data) { (result: AnyObject!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("\(error)")
                return
            }
            
            // Update ordered view
            self.cancelOrderActivityIndicator.stopAnimating()
            self.cancelOrderButton.hidden = false
            self.displayDinnerOrdered(false)
            
            // Update table
            self.getPeopleEatingTonight(true, completion: nil)
        }
    }
    
    @IBAction func editSpecialRequest(sender: AnyObject) {
        if (userOrderIndex == nil) {
            return
        }
        
        let userDinnerOrder = dinnerOrdersTonight[userOrderIndex!]
        
        println("special request: \(userDinnerOrder.specialRequest)")
        
        var noteViewController = storyboard?.instantiateViewControllerWithIdentifier(kNoteViewControllerID) as NoteViewController
        noteViewController.initialize(userDinnerOrder.specialRequest, title: "Dinner Request", allowEmpty: true) { (text: String) -> Void in
            
            println(text)
            
            var dinnerRequest = DinnerRequest(date: NSDate(), specialRequest: text)
            
            println(dinnerRequest.specialRequest)
            println(dinnerRequest.data)
            
            PFCloud.callFunctionInBackground("dinnerMakeOrder", withParameters: dinnerRequest.data, block: { (result: AnyObject!, error: NSError!) -> Void in
                if (error != nil) {
                    NSLog("\(error)")
                    return
                }
                
                // Update table
                self.getPeopleEatingTonight(true, completion: nil)
            })
        }
        presentViewController(noteViewController, animated: true, completion: nil)
    }
    
    @IBAction func onCalendarButton(sender: AnyObject) {
        
    }
    
    func updateTimer() {
        if (dinnerConfig == nil) {
            return
        }
        
        var timeToOrder = timeUntil(dinnerConfig!.deadline.hours, dinnerConfig!.deadline.minutes)
        var countdownLabelText = ""
        
        if (timeToOrder > kCountdownRedTime) {
            self.countdownLabel.textColor = UIColor.blackColor()
        } else {
            self.countdownLabel.textColor = kCountdownRedColor
        }
        
        if (timeToOrder < 0) {
            countdownLabelText = "-"
            timeToOrder = -timeToOrder
        }
        
        var hour = Int(timeToOrder) / 3600
        var minute = Int(timeToOrder) / 60 % 60
        var second = Int(timeToOrder) % 60

        countdownLabelText += NSString(format: "%u:%02u:%02u", hour, minute, second)
        self.countdownLabel.text = countdownLabelText
    }
    
    private func displayDinnerOrdered(dinnerOrdered: Bool) {
        UIView.animateWithDuration(0.1) { () -> Void in
            self.notOrderedView.alpha = dinnerOrdered ? 0 : 1
        }
    }
    
    private func updateNumPeopleOrdered(numberOrdered: Int) {
        if (numberOrdered == 1) {
            numPeopleOrdered.text = "1 Person Ordered".uppercaseString
        } else {
            numPeopleOrdered.text = "\(numberOrdered) People Ordered".uppercaseString
        }
        
        minimumPeopleMetLabel.hidden = dinnerConfig == nil || numberOrdered >= dinnerConfig?.minPeople
    }
    
    private func updateSpecialRequest() {
        var specialRequestText : String?
        if (userOrderIndex != nil) {
            let order = dinnerOrdersTonight[userOrderIndex!]
            specialRequestText = order.specialRequest
            specialRequestLabel.text = specialRequestText?
        }
        specialRequestEmptyView.hidden = specialRequestText != nil && specialRequestText != ""
    }
    
    private func findUserOrder(orders: [DinnerOrder]) -> Int? {
        for (i, order) in enumerate(orders) {
            if (order.userInfo.id == PFUser.currentUser().objectId) {
                return i
            }
        }
        return nil
    }
}
