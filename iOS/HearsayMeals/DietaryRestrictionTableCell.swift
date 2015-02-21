//
//  DietaryRestrictionTableCell.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/14/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

private let kSwitchColorOn = UIColor(red: 227 / 255.0, green: 26 / 255.0, blue: 28 / 255.0, alpha: 1)
//private let kSwitchColorOff = UIColor(red: 82 / 255.0, green: 212 / 255.0, blue: 104 / 255.0, alpha: 1)

class DietaryRestrictionTableCell : UITableViewCell {
    var imageName : String!
    var labelText : String?
    
    private var switchView = UISwitch()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        switchView.onTintColor = kSwitchColorOn
//        switchView.backgroundColor = kSwitchColorOff
//        switchView.tintColor = kSwitchColorOff
        switchView.layer.cornerRadius = 16
        switchView.addTarget(self, action: "didSwitchChange:", forControlEvents: UIControlEvents.ValueChanged)
        self.accessoryView = switchView
    }
    
    func didSwitchChange(sender: UISwitch) {
        if (sender.on) {
            PFUser.currentUser().addPreference(tag)
        } else {
            PFUser.currentUser().removePreference(tag)
        }
        PFUser.currentUser().saveInBackgroundWithBlock { (Bool, error: NSError!) -> Void in
            if (error != nil) {
                sender.on = !sender.on
                self.update()
                return
            }
        }
        self.update()
    }
    
    func setSwitch(on: Bool) {
        switchView.on = on
        update()
    }
    
    func initialize() {
        labelText = textLabel?.text
        updateImage()
    }
    
    private func updateImage() {
        if (imageName != nil) {
            let name = (switchView.on ? "no_" : "") + imageName!
            imageView?.image = UIImage(named: name)
        }
    }
    
    private func updateLabel() {
        if (labelText != nil) {
            let text = (switchView.on ? "No " : "") + labelText!
            textLabel?.text = text
        }
    }
    
    private func update() {
        updateImage()
        updateLabel()
    }
}