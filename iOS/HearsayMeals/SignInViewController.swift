//
//  SignInViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/11/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

private let kDomain = "hearsaycorp.com"

private var kDomainErrorText = "Only Hearsay Social employees can use Hearsay Meals. Please log in with your \(kDomain) account."

class SignInViewController: UIViewController, GPPSignInDelegate {
    @IBOutlet weak var errorTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var signIn = GPPSignIn.sharedInstance()
        signIn.shouldFetchGooglePlusUser = true
        signIn.clientID = kGoogleClientId
        signIn.scopes = [ kGTLAuthScopePlusUserinfoEmail, kGTLAuthScopeCalendarReadonly ]
        signIn.delegate = self

        let success = signIn.trySilentAuthentication()
        NSLog("Silent Auth %s", success ? "successfull" : "failed")
    }
    
    func finishedWithAuth (auth: GTMOAuth2Authentication, error: NSError?) {
        if (error != nil) {
            NSLog("Received error %@ and auth object %@", error!, auth)
            showError(error!.localizedDescription)
        } else {
            var sharedInstance = GPPSignIn.sharedInstance()
            var googlePlusUser = sharedInstance.googlePlusUser
            
            if (googlePlusUser.domain != kDomain) {
                NSLog("Wrong domain: %@", googlePlusUser.domain == nil ? "nil" : googlePlusUser.domain)
                GPPSignIn.sharedInstance().signOut()
                GPPSignIn.sharedInstance().disconnect()
                showError(kDomainErrorText)
                return
            }
            
            logInWithParse(googlePlusUser)
        }
    }
    
    func logInWithParse(googlePlusUser: GTLPlusPerson) {
        var userEmail = (googlePlusUser.emails[0] as GTLPlusPersonEmailsItem).value
        
        PFUser.logInWithUsernameInBackground(userEmail, password: kUserPassword, block: { (parseUser: PFUser!, error: NSError!) -> Void in
            if (parseUser == nil || error != nil) {
                NSLog("%@ does not exist in Parse", userEmail)
                var user = PFUser()
                user.email = userEmail
                user.username = userEmail
                user.password = kUserPassword
                user[kUserNameKey] = googlePlusUser.displayName
                user[kUserPictureKey] = googlePlusUser.image.url
                
                user.signUpInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                    if (error != nil) {
                        NSLog("Received error %@ creating user", error)
                        self.showError(error!.localizedDescription)
                    } else {
                        NSLog("Successfully created user %@", userEmail)
                        self.presentTabView()
                    }
                })
            } else {
                NSLog("%@ logged in to Parse successfully", userEmail)
                self.presentTabView()
            }
        })
    }
    
    func showError(error: String) {
        errorTextView.text = error
        errorTextView.hidden = false
    }
    
    func presentTabView() {
        // Hide the error if there was one earlier
        errorTextView.hidden = true
        
        let tabViewController = storyboard?.instantiateViewControllerWithIdentifier("tabViewController") as UIViewController?
        if (tabViewController != nil) {
            presentViewController(tabViewController!, animated: true, completion: nil)
        } else {
            NSLog("Can't find modal")
        }
    }
    
    func presentSignInViewController(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated:true)
    }
}
