//
//  UpdateAlertViewDelegate.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 1/10/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import UIKit

private var delegate = UpdateAlertViewDelegate()

private class UpdateAlertViewDelegate: NSObject, UIAlertViewDelegate {
    var applicationUrl: String?
    
    override init() {
        super.init()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex != 0) { // Update button
            UIApplication.sharedApplication().openURL(NSURL(string: applicationUrl!)!)
        }
    }
}