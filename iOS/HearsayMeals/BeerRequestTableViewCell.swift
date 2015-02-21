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
    
    private var requestId : String?
    private var beer : Beer?
    private var votes = [UserInfo]()
    
    func loadView(beerRequest: BeerRequest) {
        requestId = beerRequest.id
        beer = beerRequest.beer
        votes = beerRequest.votes
        
        beerLabel.text = beer!.name
        updateVotes(nil)
    }
    
    private func updateVotes(completion: (() -> Void)?) {
        var userVote = UserInfo.findUser(votes, user: PFUser.currentUser()) != nil
        
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
        if (requestId == nil) {
            return
        }
        
        // Toggle vote
        voteButton.selected = !voteButton.selected
        
        let functionName = voteButton.selected ? "beerVoteForRequest" : "beerUnvoteForRequest"
        PFCloud.callFunctionInBackground(functionName, withParameters: IdData(id: requestId!).data) { (result: AnyObject!, error: NSError!) -> Void in
            if (error != nil || result == nil) {
                NSLog("\(error)")
                return
            }
            
            // Update to the most recent votes
            self.votes = UserInfo.arrayFromData(result as [NSDictionary]?)
            self.updateVotes(nil)
        }
    }
}
