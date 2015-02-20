//
//  DinnerPeopleTableCell.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/11/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class DinnerPeopleTableCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var specialRequestLabel: UILabel!
    
    internal func update(name: String, pictureURL: String, specialRequest: String?) {
        nameLabel.text = name
        profileImage.image = loadImageFromURL(pictureURL)
        updateSpecialRequest(specialRequest)
    }
    
    internal func updateSpecialRequest(specialRequest: String?) {
        specialRequestLabel.text = specialRequest == nil ? "" : specialRequest
    }
}
