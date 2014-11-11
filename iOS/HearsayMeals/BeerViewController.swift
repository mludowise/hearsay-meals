//
//  BeerViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/8/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

var emptyKegReports : [String] = []
var kegRequests = [
    (name: "Some kind of belgian", requests: ["mludowise@hearsaycorp.com"]),
    (name: "Racer 5", requests: ["pcockwell@hearsaycorp.com"])
]

private let kCellReuseIdentifier = "requestCell"

class BeerViewController: UITableViewController {//, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerSubView: UIView!
    
    @IBOutlet weak var kickedView: UIView!
    @IBOutlet weak var emptyKegReportsLabel: UILabel!
    
    @IBOutlet weak var currentKegLabel: UILabel!
    
    @IBOutlet weak var reportEmptyButton: UIButton!
    @IBOutlet weak var reportEmptyActivityIndicator: UIActivityIndicatorView!
    
    private var beerRequests : [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        
        reportEmptyButton.selected = find(emptyKegReports, PFUser.currentUser().email) != nil
        
        kickedView.hidden = true
        headerSubView.frame.origin.y -= kickedView.frame.height
        headerSubView.frame.size.height -= kickedView.frame.height
    }
    
    override func viewDidAppear(animated: Bool) {
        updateKegReport()
//        updateBeerRequests()
    }
    
    private func updateBeerRequests() {
        var beerRequestQuery = PFQuery(className: kBeerRequestTableKey)
        beerRequestQuery.whereKey(kBeerRequestInactiveKey, notEqualTo: true)
        beerRequestQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("%@", error)
            } else {
                println("loading \(objects?.count) beer requests")
                if (objects != nil) {
                    self.beerRequests = objects as [PFObject]!
                    self.tableView.beginUpdates()
                    self.tableView.reloadData()
//                    self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: kegRequests.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
                    self.tableView.endUpdates()
                } else {
                    println("nil")
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return beerRequests.count
        return kegRequests.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier) as RequestTableViewCell
        cell.beer = kegRequests[indexPath.row].name
//        var beerRequest = beerRequests[indexPath.row]
//        cell.beer = beerRequest[kBeerRequestNameKey] as String
        
//        var query = PFQuery(className: kBeerVotesTableKey)
//        query.whereKey(kBeerVotesBeerKey, equalTo: beerRequest.objectId)
//        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
//            if (error == nil) {
////                cell.votes = objects as [PFObject]
//            }
//        }
        
        
        cell.loadView()
        return cell
    }
    
    @IBAction func onReportEmpty(sender: AnyObject) {
        reportEmptyActivityIndicator.startAnimating()
        reportEmptyButton.setTitle(reportEmptyButton.currentTitle, forState: UIControlState.Disabled)
        reportEmptyButton.enabled = false
        delay(1, { () -> () in
            self.reportEmptyActivityIndicator.stopAnimating()
            self.reportEmptyButton.enabled = true
            self.reportEmptyButton.selected = !self.reportEmptyButton.selected
            
            var index = find(emptyKegReports, PFUser.currentUser().email)
            if (index != nil) {
                emptyKegReports.removeAtIndex(index!)
            } else {
                emptyKegReports.append(PFUser.currentUser().email)
            }
            
            self.updateKegReport()
        })
    }
    
    private func updateKegReport() {
        if (emptyKegReports.count > 0) {
            emptyKegReportsLabel.text = "Reported by \(emptyKegReports.count) people"
            if (kickedView.hidden) {
                kickedView.hidden = false
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.tableView.contentOffset.y = 0
                }, completion: { (Bool) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.headerSubView.frame.origin.y -= self.kickedView.frame.height
                        self.headerSubView.frame.size.height -= self.kickedView.frame.height
                    })
                })
            }
        } else if (!kickedView.hidden) {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.tableView.contentOffset.y = 0
                }, completion: { (Bool) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.headerSubView.frame.origin.y -= self.kickedView.frame.height
                        self.headerSubView.frame.size.height -= self.kickedView.frame.height
                        }, completion: { (Bool) -> Void in
                            self.kickedView.hidden = true
                    })
            })
        }
    }
    
    @IBAction func onMakeRequest(sender: AnyObject) {
        var noteViewController = storyboard?.instantiateViewControllerWithIdentifier(kNoteViewControllerID) as NoteViewController
        noteViewController.title = "Request Beer"
        noteViewController.onDone = { (text: String) -> Void in
            kegRequests.append(name: text, requests: [PFUser.currentUser().email])
            self.tableView.reloadData()
        }
        presentViewController(noteViewController, animated: true, completion: nil)
    }
}