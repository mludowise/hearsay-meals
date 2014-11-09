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
    
    @IBOutlet weak var requestsTable: UITableView!
    @IBOutlet weak var makeRequestView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestsTable.dataSource = self
        
        reportEmptyButton.selected = find(emptyKegReports, userEmail) != nil
        
        kickedView.hidden = true
        mainView.frame.origin.y = 0
    }
    
    override func viewDidAppear(animated: Bool) {
        requestsTable.frame.size = requestsTable.contentSize
        makeRequestView.frame.origin.y = requestsTable.frame.origin.y + requestsTable.frame.height + 20
        mainView.frame.size.height = makeRequestView.frame.origin.y + makeRequestView.frame.height
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: mainView.frame.origin.y + mainView.frame.height)
        
        updateKegReport()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kegRequests.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier) as RequestTableViewCell
        cell.beer = kegRequests[indexPath.row].name
        cell.votes = kegRequests[indexPath.row].requests
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
            
            var index = find(emptyKegReports, userEmail)
            if (index != nil) {
                emptyKegReports.removeAtIndex(index!)
            } else {
                emptyKegReports.append(userEmail)
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
    
    @IBAction func onMakeRequest(sender: AnyObject) {
        var noteViewController = storyboard?.instantiateViewControllerWithIdentifier(kNoteViewControllerID) as NoteViewController
        noteViewController.title = "Request Beer"
        noteViewController.onDone = { (text: String) -> Void in
            kegRequests.append(name: text, requests: [userEmail])
            self.requestsTable.beginUpdates()
            self.requestsTable.insertRowsAtIndexPaths([NSIndexPath(forRow: kegRequests.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            self.requestsTable.endUpdates()
        }
        presentViewController(noteViewController, animated: true, completion: nil)
    }
}
