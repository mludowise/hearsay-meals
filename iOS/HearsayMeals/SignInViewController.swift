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

private var kTabViewControllerId = "tabViewController"

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
        let successString = success ? "Successfull" : "Failed"
        NSLog("Silent Auth \(successString)")
    }
    
    // Callback when Google+ finishes authorizing
    func finishedWithAuth (auth: GTMOAuth2Authentication, error: NSError?) {
        if (error != nil) {
            NSLog("Received error \(error) and auth object \(auth)")
            showError(error!.localizedDescription)
        } else {
            var sharedInstance = GPPSignIn.sharedInstance()
            var googlePlusUser = sharedInstance.googlePlusUser
            
            if (googlePlusUser.domain != kDomain) {
                NSLog("Wrong domain: \(googlePlusUser.domain)")
                GPPSignIn.sharedInstance().signOut()
                GPPSignIn.sharedInstance().disconnect()
                showError(kDomainErrorText)
                return
            }
            
            logInWithParse(googlePlusUser)
        }
    }
    
    // Logic to log into Hearsay Meals using Parse (or create new account)
    func logInWithParse(googlePlusUser: GTLPlusPerson) {
        var userEmail = (googlePlusUser.emails[0] as GTLPlusPersonEmailsItem).value
        
        PFUser.logInWithUsernameInBackground(userEmail, password: PFUser.password(), block: { (parseUser: PFUser!, error: NSError!) -> Void in
            if (parseUser == nil || error != nil) {
                NSLog("\(userEmail) does not exist in Parse")
                var user = PFUser()
                user.email = userEmail
                user.username = userEmail
                user.password = PFUser.password()
                user.name = googlePlusUser.displayName
                user.pictureURL = googlePlusUser.image.url
                
                user.signUpInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                    if (error != nil) {
                        NSLog("Received error \(error) creating user")
                        self.showError(error!.localizedDescription)
                    } else {
                        NSLog("Successfully created user \(userEmail)")
                        self.presentTabView()
                    }
                })
            } else {
                NSLog("\(userEmail) logged in to Parse successfully")
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
        
        let tabViewController = storyboard?.instantiateViewControllerWithIdentifier(kTabViewControllerId) as UIViewController?
        if (tabViewController != nil) {
            presentViewController(tabViewController!, animated: true, completion: nil)
        } else {
            NSLog("Can't find \(kTabViewControllerId)")
        }
    }
    
    func presentSignInViewController(viewController: UIViewController) {
        self.navigationController?.pushViewController(viewController, animated:true)
    }
}
