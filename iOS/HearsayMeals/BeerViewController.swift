//
//  BeerViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/8/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

private let kCellIdentifier = "BeerRequestTableCell"
private let kSectionFooterIdentifier = "BeerRequestSectionFooter"

class BeerViewController: UITableViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerSubView: UIView!
    
    @IBOutlet weak var kickedView: UIView!
    @IBOutlet weak var emptyKegReportsLabel: UILabel!
    
    @IBOutlet weak var currentKegLabel: UILabel!
    
    @IBOutlet weak var reportEmptyButton: UIButton!
    @IBOutlet weak var reportEmptyActivityIndicator: UIActivityIndicatorView!
    
    private var beerRequests = [BeerRequest]()
    private var kegId : String?
    private var beer : Beer?
    private var kickedReports = [UserInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background to clear so it doesn't look blue when selected
        reportEmptyButton.backgroundColor = UIColor.clearColor()
        reportEmptyButton.tintColor = UIColor.clearColor()
        
        kickedView.hidden = true
        currentKegLabel.text = ""
        
        headerSubView.frame.origin.y -= kickedView.frame.height
        headerView.frame.size.height -= kickedView.frame.height
        tableView.tableHeaderView = headerView
        updateKeg { () -> Void in
            self.updateKegKickedView()
            self.updateTabBadge()
        }
        updateBeerRequests(nil)
    }
    
    @IBAction func onRefreshTable(sender: UIRefreshControl) {
        var updatedKeg = false
        var updatedRequests = false
        updateKeg { () -> Void in
            self.updateKegKickedView()
            self.updateTabBadge()
            updatedKeg = true
            if (updatedRequests) {
                sender.endRefreshing()
            }
        }
        updateBeerRequests { () -> Void in
            updatedRequests = true
            if (updatedKeg) {
                sender.endRefreshing()
            }
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Beer Requests"
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerRequests.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier) as BeerRequestTableViewCell
        cell.loadView(beerRequests[indexPath.row])
        return cell
    }
    
    private func updateKeg(completion: (() -> Void)?) {
        PFCloud.callFunctionInBackground("beerOnTap", withParameters: [:]) { (result: AnyObject!, error: NSError!) -> Void in
            if (error != nil || result == nil) {
                NSLog("\(error)")
                return
            }
            
            let beerOnTap = BeerOnTap(data: result as NSDictionary)
            self.beer = beerOnTap.beer
            self.kegId = beerOnTap.id
            self.kickedReports = beerOnTap.kickedReports
            
            // Update current keg
            self.currentKegLabel.text = self.beer?.name
            
            // Disable report empty keg button if user already reported it
            self.reportEmptyButton.selected = UserInfo.findUser(self.kickedReports, user: PFUser.currentUser()) != nil
            completion?()
        }
    }
    
    private func updateKegKickedView() {
        // Scroll to the top of the view
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.tableView.contentOffset.y = -self.tableView.contentInset.top
        })
        
        if (kickedReports.count > 0) { // Keg is kicked
            // Flash empty report off and on to update it
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.emptyKegReportsLabel.alpha = 0
            }, completion: { (Bool) -> Void in
                let numPeople = self.kickedReports.count
                self.emptyKegReportsLabel.text = numPeople == 1 ? "Reported by 1 person" : "Reported by \(numPeople) people"
                UIView.animateWithDuration(0.4, delay: 0.1, options: nil, animations: { () -> Void in
                    self.emptyKegReportsLabel.alpha = 1
                }, completion: nil)
            })
            
            // If we're not showing the kicked banner already, animate it
            if (kickedView.hidden) {
                kickedView.hidden = false
                UIView.animateWithDuration(0.4, delay: 0.1, options: nil, animations: { () -> Void in
                    self.headerSubView.frame.origin.y += self.kickedView.frame.height
                    self.headerView.frame.size.height += self.kickedView.frame.height
                    self.tableView.tableHeaderView = self.headerView
                    }, completion: nil)
            }
        } else if (!kickedView.hidden) { // Keg isn't kicked & we haven't marked it as such
            // If kicked banner isn't already hidden, hide it
            UIView.animateWithDuration(0.4, delay: 0.1, options: nil, animations: { () -> Void in
                self.headerSubView.frame.origin.y -= self.kickedView.frame.height
                self.headerView.frame.size.height -= self.kickedView.frame.height
                self.tableView.tableHeaderView = self.headerView
                }, completion: { (Bool) -> Void in
                    self.kickedView.hidden = true
            })
        }
    }
    
    private func updateTabBadge() {
        var value : String?
        
        if (kickedReports.count > 0) { // Keg is kicked
            value = "!"
        }
        
        tabBarItem?.badgeValue = value
        navigationController?.tabBarItem?.badgeValue = value
    }
    
    @IBAction func onReportEmpty(sender: AnyObject) {
        if (kegId == nil) {
            return
        }
        
        reportEmptyActivityIndicator.startAnimating()
        
        let functionName = reportEmptyButton.selected ? "beerUnreportKicked" : "beerReportKicked"
        
        PFCloud.callFunctionInBackground(functionName, withParameters: IdData(id: kegId!).data) { (result: AnyObject!, error: NSError!) -> Void in
            if (error != nil || result == nil) {
                NSLog("\(error)")
                return
            }
            
            self.kickedReports = UserInfo.arrayFromData(result as [NSDictionary]?)
            
            self.reportEmptyActivityIndicator.stopAnimating()
            self.reportEmptyButton.selected = !self.reportEmptyButton.selected
            self.updateKegKickedView()
            self.updateTabBadge()
        }
    }
    
    private func updateBeerRequests(completion: (() -> Void)?) {
        PFCloud.callFunctionInBackground("beerGetRequests", withParameters: CloudDataUtil.empty()) { (result: AnyObject!, error: NSError!) -> Void in
            if (error != nil || result == nil) {
                NSLog("\(error)")
                return
            }
            
            self.beerRequests = BeerRequest.arrayFromData(result as [NSDictionary]?)
            self.tableView.reloadData()
            completion?()
        }
    }
    
    @IBAction func onMakeRequest(sender: AnyObject) {
        var noteViewController = storyboard?.instantiateViewControllerWithIdentifier(kNoteViewControllerID) as NoteViewController
        noteViewController.initialize(nil, title: "Beer Request", allowEmpty: false) { (text: String) -> Void in
            let beer = Beer(name: text)
            PFCloud.callFunctionInBackground("beerAddRequest", withParameters: beer.data, block: { (result: AnyObject!, error: NSError!) -> Void in
                if (error != nil) {
                    NSLog("\(error)")
                    var alertView = UIAlertView(title: "Woops!", message: "Someone has already requested '\(text)'. Instead, why don't you vote for '\(text)'?", delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                    self.updateBeerRequests(nil)
                    return
                }
                
                if (result == nil) {
                    NSLog("Empty Result")
                    return
                }
                
                self.updateBeerRequests(nil)
            })
        }
        presentViewController(noteViewController, animated: true, completion: nil)
    }
}