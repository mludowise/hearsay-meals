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

class BeerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var kickedView: UIView!
    @IBOutlet weak var emptyKegReportsLabel: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var reportEmptyButton: UIButton!
    @IBOutlet weak var reportEmptyActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var requestsView: UIView!
    @IBOutlet weak var requestsTable: UITableView!
    @IBOutlet weak var makeRequestView: UIView!
    
    
    private var beerRequests : [PFObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestsTable.dataSource = self
        reportEmptyButton.selected = find(emptyKegReports, PFUser.currentUser().email) != nil
        
        kickedView.hidden = true
        mainView.frame.origin.y = 0
        adjustRequestTableHeight()
    }
    
    override func viewDidAppear(animated: Bool) {
//        updateBeerRequests()
        var beerRequestQuery = PFQuery(className: kBeerRequestTableKey)
        beerRequestQuery.whereKey(kBeerRequestInactiveKey, notEqualTo: true)
        beerRequestQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error != nil) {
                NSLog("%@", error)
            } else {
                if (objects != nil) {
                    self.beerRequests = objects as [PFObject]!
                    self.updateBeerRequests()
                }
            }
        }
        updateKegReport()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beerRequests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier) as RequestTableViewCell
        var beerRequest = beerRequests[indexPath.row]
//        cell.beer = beerRequest[kBeerRequestNameKey] as String
        
        var query = PFQuery(className: kBeerVotesTableKey)
        query.whereKey(kBeerVotesBeerKey, equalTo: beerRequest.objectId)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if (error == nil) {
//                cell.votes = objects as [PFObject]
            }
        }
        
        
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
                kickedView.frame.origin.y = -kickedView.frame.height
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.scrollView.contentOffset.y = 0
                }, completion: { (Bool) -> Void in
                    UIView.animateWithDuration(0.5, animations: { () -> Void in
                        self.kickedView.frame.origin.y = 0
                        self.mainView.frame.origin.y = self.kickedView.frame.height
                    })
                })
            }
        } else {
            if (!kickedView.hidden) {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.scrollView.contentOffset.y = 0
                    }, completion: { (Bool) -> Void in
                        UIView.animateWithDuration(0.5, animations: { () -> Void in
                            self.kickedView.frame.origin.y = -self.kickedView.frame.height
                            self.mainView.frame.origin.y = 0
                            }, completion: { (Bool) -> Void in
                                self.kickedView.hidden = true
                        })
                })
            }
        }
    }
    
    private func updateBeerRequests() {
        println("Updating.... \(beerRequests.count) requests")
        
        adjustRequestTableHeight()
        
        requestsTable.beginUpdates()
        var paths = [NSIndexPath]()
        
        var i = 0
        for beerRequest in beerRequests {
            paths.append(NSIndexPath(forRow: i, inSection: 0))
            i++
        }
        requestsTable.insertRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Automatic)
        requestsTable.endUpdates()
    }
    
    private func adjustRequestTableHeight() {
        if (beerRequests.count == 0) {
            requestsView.hidden = true
            makeRequestView.frame.origin.y = requestsView.frame.origin.y
        } else {
            requestsView.hidden = false
            println(requestsTable.rowHeight)
            requestsTable.frame.size.height = requestsTable.rowHeight * CGFloat(beerRequests.count)
            requestsView.frame.size.height = requestsTable.frame.origin.y + requestsTable.frame.height
            makeRequestView.frame.origin.y = requestsView.frame.origin.y + requestsView.frame.height + 20
        }
        mainView.frame.size.height = makeRequestView.frame.origin.y + makeRequestView.frame.height
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: mainView.frame.origin.y + mainView.frame.height)
    }
    
    @IBAction func onMakeRequest(sender: AnyObject) {
        var noteViewController = storyboard?.instantiateViewControllerWithIdentifier(kNoteViewControllerID) as NoteViewController
        noteViewController.title = "Request Beer"
        noteViewController.onDone = { (text: String) -> Void in
            kegRequests.append(name: text, requests: [PFUser.currentUser().email])
            self.requestsTable.beginUpdates()
            self.requestsTable.insertRowsAtIndexPaths([NSIndexPath(forRow: kegRequests.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.requestsTable.endUpdates()
        }
        presentViewController(noteViewController, animated: true, completion: nil)
    }
}