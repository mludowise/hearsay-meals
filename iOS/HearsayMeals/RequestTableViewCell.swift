//
//  RequestTableViewCell.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/8/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class RequestTableViewCell: UITableViewCell {

    @IBOutlet weak var beerLabel: UILabel!
    @IBOutlet weak var voteButton: UIButton!
    
    var beerRequest : PFObject?
    private var userVote : PFObject?
    private var votes = [PFObject]()
    
    func loadView() {
        if (beerRequest != nil) {
            beerLabel.text = beerRequest![kBeerRequestNameKey] as? String
            
            // Hide button and show loading while checking on # of votes
            voteButton.hidden = true
            updateVotes({ () -> Void in
                self.voteButton.hidden = false
            })
        } else {
            voteButton.hidden = true
        }
    }
    
    private func updateVotes(completion: (() -> Void)?) {
        var query = PFQuery(className: kBeerVotesTableKey)
        query.whereKey(kBeerVotesBeerKey, equalTo: beerRequest?.objectId)
        query.findObjectsInBackgroundWithBlock({ (results:[AnyObject]!, error: NSError!) -> Void in
            self.votes = results? as [PFObject]
            self.userVote = self.findUserVote()

            // Figure out how many votes should display when the button is deselected
            var numVotesWithoutUser = self.votes.count
            if (self.userVote != nil) {
                numVotesWithoutUser--
            }
            
            self.voteButton.selected = self.userVote != nil
            self.voteButton.setTitle("+\(numVotesWithoutUser)", forState: UIControlState.Normal)
            self.voteButton.setTitle("+\(numVotesWithoutUser + 1)", forState: UIControlState.Selected)
            
            completion?()
        })
    }
    
    @IBAction func onVoteButton(sender: AnyObject) {
        // Check if user voted before clicking this button
        var voted = userVote != nil
        
        // Update to the most recent votes
        updateVotes(nil)
        
        if (voted) { // Unvote
            userVote?.deleteInBackground()
        } else if (userVote == nil) { // Vote if there's no record of a vote
            var userVote = PFObject(className: kBeerVotesTableKey)
            userVote[kBeerVotesBeerKey] = self.beerRequest?.objectId
            userVote[kBeerVotesUserKey] = PFUser.currentUser().objectId
            userVote.saveInBackground()
        }
    }
    
    private func findUserVote() -> PFObject? {
        for vote in votes {
            if (vote[kBeerRequestUserKey] as String == PFUser.currentUser().objectId) {
                return vote
            }
        }
        return nil
    }
}
