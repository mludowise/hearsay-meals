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
    
    var beer = ""
    var votes : [String] = []
    private var voted = false
    
    func loadView() {
//        voteButton.setBackgroundImage(nil, forState: UIControlState.Selected)
//        voteButton.layer.borderWidth = 1
//        voteButton.layer.borderColor = voteButton.currentTitleColor.CGColor
        
        beerLabel.text = beer
        
        var numVotesWithoutUser = votes.count
        if (find(votes, userEmail) != nil) {
            voted = true
            numVotesWithoutUser--
        }
        voteButton.selected = voted
        voteButton.setTitle("+\(numVotesWithoutUser)", forState: UIControlState.Normal)
        voteButton.setTitle("+\(numVotesWithoutUser + 1)", forState: UIControlState.Selected)
    }
    
    @IBAction func onVoteButton(sender: AnyObject) {
        if (voted) {
            var emailIndex = find(votes, userEmail)!
            votes.removeAtIndex(emailIndex)
        } else {
            votes.append(userEmail)
        }
        
        voted = !voted
        voteButton.selected = voted
    }
}
