//
//  UpdateUtil.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 1/18/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

private var delegate = UpdateAlertViewDelegate()
//private var appVersion : Float = 0
//private var bundleID = ""

// Returns whether the app needs to be updated or not
func checkForUpdates(finished: ((Bool) -> Void)?) {
    // Check app version
    var appVersion = (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as NSString).floatValue
    
    NSLog("App Version: \(appVersion)")
    
    PFCloud.callFunctionInBackground("applicationsGetLatest", withParameters: ApplicationPlatform().data) { (result: AnyObject!, error: NSError!) -> Void in
        if (error != nil) {
            NSLog("\(error)")
            return
        }
        
        let latest = ApplicationProperty(data: result as NSDictionary)
        let latestVersion = latest.version
        NSLog("Latest Version: \(latestVersion)")
        
        if (latestVersion <= appVersion) {
            finished?(false)
            return
        }
        
        // Present modal asking the user if they'd like to update to the latest version
        delegate.applicationUrl = latest.url
        
        var alertView = UIAlertView(title: "Version \(latestVersion) Available",
            message: "Please update to the latest version.",
            delegate: delegate,
            cancelButtonTitle: "Not Now",
            otherButtonTitles: "Update")
        alertView.show()
        finished?(true)
    }
}

private class UpdateAlertViewDelegate: NSObject, UIAlertViewDelegate {
    var applicationUrl : String?
    
    override init() {
        super.init()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if (buttonIndex != 0) { // Update button
            UIApplication.sharedApplication().openURL(NSURL(string: applicationUrl!)!)
        }
    }
}

