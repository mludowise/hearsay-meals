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

//var emptyKegReports : [String] = []

class BeerViewController: UITableViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerSubView: UIView!
    
    @IBOutlet weak var kickedView: UIView!
    @IBOutlet weak var emptyKegReportsLabel: UILabel!
    
    @IBOutlet weak var currentKegLabel: UILabel!
    
    @IBOutlet weak var reportEmptyButton: UIButton!
    @IBOutlet weak var reportEmptyActivityIndicator: UIActivityIndicatorView!
    
    private var beerRequests = [PFObject]()
    private var keg: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        kickedView.hidden = true
        currentKegLabel.text = ""
        
        headerSubView.frame.origin.y -= kickedView.frame.height
        headerView.frame.size.height -= kickedView.frame.height
        tableView.tableHeaderView = headerView
        
        updateKeg(updateKegKickedView)
        updateBeerRequests(nil)
    }
    
    @IBAction func onRefreshTable(sender: UIRefreshControl) {
        var updatedKeg = false
        var updatedRequests = false
        updateKeg { () -> Void in
            self.updateKegKickedView()
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
        cell.beerRequest = beerRequests[indexPath.row]
        cell.loadView()
        return cell
    }
    
    private func updateKeg(completion: (() -> Void)?) {
        var query = PFQuery(className: kKegTableKey)
        query.orderByDescending(kCreatedAtKey)
        query.getFirstObjectInBackgroundWithBlock { (keg: PFObject!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("%@", error)
            } else {
                self.keg = keg
                
                // Update current keg
                self.currentKegLabel.text = keg[kKegBeerNameKey] as? String
                
                // Disable report empty keg button if user already reported it
                if (keg[kKegKickedReportsKey] != nil) {
                    self.reportEmptyButton.selected = find(keg[kKegKickedReportsKey] as [String], PFUser.currentUser().objectId) != nil
                }
                completion?()
            }
        }
    }
    
    private func updateKegKickedView() {
        // Scroll to the top of the view
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.tableView.contentOffset.y = -self.tableView.contentInset.top
        })
        
        if ((keg?[kKegKickedReportsKey] as [String]).count > 0) {
            // Flash empty report off and on to update it
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.emptyKegReportsLabel.alpha = 0
            }, completion: { (Bool) -> Void in
                self.emptyKegReportsLabel.text = "Reported by \((self.keg?[kKegKickedReportsKey] as [String]).count) people"
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
        } else if (!kickedView.hidden) {
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
    
    @IBAction func onReportEmpty(sender: AnyObject) {
        reportEmptyActivityIndicator.startAnimating()
        
        if (reportEmptyButton.selected) { // User already reported as kicked
            keg?.removeObjectsInArray([PFUser.currentUser().objectId], forKey: kKegKickedReportsKey)
        } else {
            keg?.addUniqueObject(PFUser.currentUser().objectId, forKey: kKegKickedReportsKey)
        }
        
        keg?.saveInBackgroundWithBlock({ (b: Bool, error: NSError!) -> Void in
            self.reportEmptyActivityIndicator.stopAnimating()
            self.reportEmptyButton.selected = !self.reportEmptyButton.selected
            self.updateKegKickedView()
        })
    }
    
    private func updateBeerRequests(completion: (() -> Void)?) {
        var beerRequestQuery = PFQuery(className: kBeerRequestTableKey)
        beerRequestQuery.whereKey(kBeerRequestInactiveKey, notEqualTo: true)
        beerRequestQuery.orderByAscending(kCreatedAtKey)
        beerRequestQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("%@", error)
            } else {
                self.beerRequests = objects as [PFObject]!
                self.tableView.reloadData()
                completion?()
            }
        }
    }
    
    @IBAction func onMakeRequest(sender: AnyObject) {
        var noteViewController = storyboard?.instantiateViewControllerWithIdentifier(kNoteViewControllerID) as NoteViewController
        noteViewController.titleBarText = "Beer Request"
        noteViewController.onDone = { (text: String) -> Void in
            
            var beerRequest = PFObject(className: kBeerRequestTableKey)
            beerRequest[kBeerRequestUserKey] = PFUser.currentUser().objectId
            beerRequest[kBeerRequestNameKey] = text
            beerRequest.saveInBackgroundWithBlock({ (b: Bool, error: NSError!) -> Void in
                if (error != nil) {
                    NSLog("%@", error)
                } else {
                    // User implicitly votes for beer
                    var beerVote = PFObject(className: kBeerVotesTableKey)
                    beerVote[kBeerVotesUserKey] = PFUser.currentUser().objectId
                    beerVote[kBeerVotesBeerKey] = beerRequest.objectId
                    beerVote.saveInBackground()
                    
                    // Update table
                    self.beerRequests.append(beerRequest)
                    self.tableView.beginUpdates()
                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forItem: self.beerRequests.count-1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                    self.tableView.endUpdates()

                }
            })
            
        }
        presentViewController(noteViewController, animated: true, completion: nil)
    }
    
}