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
    private var votes : [PFObject] = []
    private var voted = false
    
    func loadView() {
        if (beerRequest != nil) {
            beerLabel.text = beerRequest![kBeerRequestNameKey] as? String
            
            var query = PFQuery(className: kBeerVotesTableKey)
            query.whereKey(kBeerVotesBeerKey, equalTo: beerRequest?.objectId)
            query.whereKey(kBeerVotesUserKey, equalTo: PFUser.currentUser().objectId)
            voted = query.findObjects().count > 0
            
            updateVotes()
        } else {
            voteButton.hidden = true
        }
    }
    
    private func updateVotes() {
        var query = PFQuery(className: kBeerVotesTableKey)
        query.whereKey(kBeerVotesBeerKey, equalTo: beerRequest?.objectId)
        votes = query.findObjects() as [PFObject]
        
        var numVotesWithoutUser = votes.count
        
        if (voted) {
            numVotesWithoutUser--
        }
        
        voteButton.selected = voted
        voteButton.setTitle("+\(numVotesWithoutUser)", forState: UIControlState.Normal)
        voteButton.setTitle("+\(numVotesWithoutUser + 1)", forState: UIControlState.Selected)
    }
    
    @IBAction func onVoteButton(sender: AnyObject) {
        var query = PFQuery(className: kBeerVotesTableKey)
        query.whereKey(kBeerVotesBeerKey, equalTo: beerRequest?.objectId)
        query.whereKey(kBeerVotesUserKey, equalTo: PFUser.currentUser().objectId)
        var userVotes = query.findObjects() as [PFObject]
        
        if (voted) { // Remove user's vote for this beer
            for userVote in userVotes {
                userVote.deleteInBackground()
            }
        } else if (userVotes.count == 0) { // Add user's vote for beer
            var userVote = PFObject(className: kBeerVotesTableKey)
            userVote[kBeerVotesBeerKey] = beerRequest?.objectId
            userVote[kBeerVotesUserKey] = PFUser.currentUser().objectId
            userVote.save()
        }
        
        voted = !voted
        updateVotes()
    }
}
