//
//  AppDelegate.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/11/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

private let kParseApplicationId = "myq9zbMzdkBqqEyudRcwIR5yxnmwihlslqUvYh34"
private let kParseClientKey = "sSDcYzwEBOuOGKYjuY28Skvalo2sImKNwXRt7v4q"

internal let kThemeColor = UIColor(red: 31/255.0, green: 120/255.0, blue: 179/255.0, alpha: 1)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String,
        annotation: AnyObject?) -> Bool {
            setupColors()
            return GPPURLHandler.handleURL(url,
                sourceApplication:sourceApplication,
                annotation:annotation)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Use Parse
        Parse.setApplicationId(kParseApplicationId,
            clientKey: kParseClientKey)
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions);
        setupColors()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    private func setupColors() {
        // Custom tab bar color
        UITabBar.appearance().tintColor = kThemeColor
        UIButton.appearance().tintColor = kThemeColor
        UINavigationBar.appearance().tintColor = kThemeColor
    }
}

