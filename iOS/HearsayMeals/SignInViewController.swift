//
//  SignInViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/11/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, GPPSignInDelegate {
    private let kClientId = "966122623899-snf8rtjucf08hup8a2jjmihcina16a0j.apps.googleusercontent.com"
    private let kDomain = "hearsaycorp.com"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var signIn = GPPSignIn.sharedInstance()
        signIn.shouldFetchGooglePlusUser = true
        signIn.clientID = kClientId
        signIn.scopes = [ kGTLAuthScopePlusUserinfoEmail, kGTLAuthScopeCalendarReadonly ]
        signIn.delegate = self

        let success = signIn.trySilentAuthentication()
        NSLog("Silent Auth %s", success ? "successfull" : "failed")
        
        // Test Parse
        var testObject = PFObject(className: "TestObject")
//            objectWithClassName: "TestObject")
        testObject["foo"] = "bar"
        testObject.saveInBackground()
    }
    
    func finishedWithAuth (auth: GTMOAuth2Authentication,
        error: NSError?) {
            if (error != nil) {
                NSLog("Received error %@ and auth object %@",error!, auth);
            } else {
                // TODO: Validate against hearsaycorp.com domain
                NSLog("Domain: %@", GPPSignIn.sharedInstance().googlePlusUser.domain);
                let tabViewController = storyboard?.instantiateViewControllerWithIdentifier("tabViewController") as UIViewController?
                if (tabViewController != nil) {
                    presentViewController(tabViewController!, animated: true, completion: nil)
                } else {
                    NSLog("Can't find modal")
                }

            }
    }
    
    func presentSignInViewController(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated:true)
    }
}
