//
//  UpdateUtil.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 1/18/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

// Returns whether the app needs to be updated or not
func checkForUpdates() -> Bool {
    // Check app version
    var appVersion = (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as NSString).floatValue
    var bundleID = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleIdentifierKey) as String
    
    println("App Version: \(appVersion)")
    println("Bundle ID: \(bundleID)")
    
    var query = PFQuery(className: kApplicationPropertiesTableKey)
    query.whereKey(kApplicationPropertiesType, equalTo: "iOS")
    query.whereKey(kApplicationPropertiesId, equalTo: bundleID)
    var applicationProperties = query.getFirstObject()
    var latestVersion = applicationProperties[kApplicationPropertiesLatestVersion] as Float
    
    if (latestVersion <= appVersion) {
        return false
    }
    
    // Present modal asking the user if they'd like to update to the latest version
    delegate.applicationUrl = applicationProperties[kApplicationPropertiesDownloadUrl] as? String
    
    var alertView = UIAlertView(title: "Version \(latestVersion) Available",
        message: "Please update to the latest version.",
        delegate: delegate,
        cancelButtonTitle: "Not Now",
        otherButtonTitles: "Update")
    alertView.show()
    
    return true
}