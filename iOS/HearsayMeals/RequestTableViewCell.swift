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
    @IBOutlet weak var votingActivityIndicator: UIActivityIndicatorView!
    
    var beerRequest : PFObject?
    private var voted = false
    
    func loadView() {
        if (beerRequest != nil) {
            beerLabel.text = beerRequest![kBeerRequestNameKey] as? String
            
            // Hide button and show loading while checking on # of votes
            voteButton.hidden = true
            votingActivityIndicator.startAnimating()
            
            var query = PFQuery(className: kBeerVotesTableKey)
            query.whereKey(kBeerVotesBeerKey, equalTo: beerRequest?.objectId)
            query.whereKey(kBeerVotesUserKey, equalTo: PFUser.currentUser().objectId)
            query.findObjectsInBackgroundWithBlock({ (objects:[AnyObject]!, error: NSError!) -> Void in
                var votes = objects? as [PFObject]
                self.voted = votes.count > 0
                
                self.updateVotes()
                self.votingActivityIndicator.stopAnimating()
                self.voteButton.hidden = false
            })
            
        } else {
            voteButton.hidden = true
        }
    }
    
    private func updateVotes() {
        var query = PFQuery(className: kBeerVotesTableKey)
        query.whereKey(kBeerVotesBeerKey, equalTo: beerRequest?.objectId)
        var votes = query.findObjects() as [PFObject]
        
        var numVotesWithoutUser = votes.count
        
        if (voted) {
            numVotesWithoutUser--
        }
        
        voteButton.selected = voted
        voteButton.setTitle("+\(numVotesWithoutUser)", forState: UIControlState.Normal)
        voteButton.setTitle("+\(numVotesWithoutUser + 1)", forState: UIControlState.Selected)
    }
    
    @IBAction func onVoteButton(sender: AnyObject) {
        voteButton.hidden = true
        votingActivityIndicator.startAnimating()
        
        var query = PFQuery(className: kBeerVotesTableKey)
        query.whereKey(kBeerVotesBeerKey, equalTo: beerRequest?.objectId)
        query.whereKey(kBeerVotesUserKey, equalTo: PFUser.currentUser().objectId)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            var userVotes = query.findObjects() as [PFObject]
            
            if (self.voted) { // Remove user's vote for this beer
                for userVote in userVotes {
                    userVote.deleteInBackground()
                }
            } else if (userVotes.count == 0) { // Add user's vote for beer
                var userVote = PFObject(className: kBeerVotesTableKey)
                userVote[kBeerVotesBeerKey] = self.beerRequest?.objectId
                userVote[kBeerVotesUserKey] = PFUser.currentUser().objectId
                userVote.save()
            }
            
            self.voted = !self.voted
            self.updateVotes()
            self.votingActivityIndicator.stopAnimating()
            self.voteButton.hidden = false
        }
    }
}
