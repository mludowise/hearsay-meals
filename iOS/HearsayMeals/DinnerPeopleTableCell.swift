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
    
    internal func update(user: PFUser, specialRequest: String?) {
        nameLabel.text = user[kUserNameKey] as? String
        profileImage.image = loadImageFromURL(user[kUserPictureKey] as String)
        updateSpecialRequest(specialRequest)
    }
    
    internal func updateSpecialRequest(specialRequest: String?) {
        specialRequestLabel.text = specialRequest == nil ? "" : specialRequest
    }
}
