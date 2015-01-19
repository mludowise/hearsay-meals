//
//  UpdateUtil.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 1/18/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

private var delegate = UpdateAlertViewDelegate()

// Returns whether the app needs to be updated or not
func checkForUpdates() -> Bool {
    // Check app version
    var appVersion = (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as NSString).floatValue
    var bundleID = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleIdentifierKey) as String
    
    println("App Version: \(appVersion)")
    println("Bundle ID: \(bundleID)")
    
    var query = PFQuery(className: kApplicationPropertiesTableKey)
    query.whereKey(kApplicationPropertiesTypeKey, equalTo: "iOS")
    query.whereKey(kApplicationPropertiesIdKey, equalTo: bundleID)
    var applicationProperties = query.getFirstObject()
    var latestVersion = applicationProperties[kApplicationPropertiesLatestVersionKey] as Float
    
    if (latestVersion <= appVersion) {
        return false
    }
    
    // Present modal asking the user if they'd like to update to the latest version
    delegate.applicationUrl = applicationProperties[kApplicationPropertiesDownloadUrlKey] as? String
    
    var alertView = UIAlertView(title: "Version \(latestVersion) Available",
        message: "Please update to the latest version.",
        delegate: delegate,
        cancelButtonTitle: "Not Now",
        otherButtonTitles: "Update")
    alertView.show()
    
    return true
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

