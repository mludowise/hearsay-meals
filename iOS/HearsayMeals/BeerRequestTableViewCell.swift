//
//  BeerRequestTableViewCell.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/8/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class BeerRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var beerLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    
    var beerRequest : PFObject?
    
    func loadView() {
        if (beerRequest != nil) {
            beerLabel.text = beerRequest![kBeerRequestNameKey] as? String
            updateVotes(nil)
        } else {
            voteButton.hidden = true
        }
    }
    
    private func updateVotes(completion: (() -> Void)?) {
        var votes = beerRequest?[kBeerRequestVotesKey] as [String]
        var userVote = find(votes, PFUser.currentUser().objectId) != nil
        
        // Figure out how many votes should display when the button is deselected
        var numVotesWithoutUser = votes.count
        if (userVote) {
            numVotesWithoutUser--
        }
        
        voteButton.selected = userVote
        voteButton.setTitle("+\(numVotesWithoutUser)", forState: UIControlState.Normal)
        voteButton.setTitle("+\(numVotesWithoutUser + 1)", forState: UIControlState.Selected)
        
        completion?()
    }
    
    @IBAction func onVoteButton(sender: AnyObject) {
        // Toggle vote
        voteButton.selected = !voteButton.selected
        
        if (voteButton.selected) { // User voted
            self.beerRequest?.addUniqueObject(PFUser.currentUser().objectId, forKey: kBeerRequestVotesKey)
        } else { // User unvoted
            self.beerRequest?.removeObject(PFUser.currentUser().objectId, forKey: kBeerRequestVotesKey)
        }
        
        // Refresh votes while we're at it
        self.beerRequest?.saveInBackgroundWithBlock({ (b: Bool, error: NSError!) -> Void in
            self.beerRequest?.refreshInBackgroundWithBlock({ (object: PFObject!, error: NSError!) -> Void in
                // Update to the most recent votes
                self.updateVotes(nil)
            })
            return () // Have to do this in one-line functions in Swift
        })
    }
}
