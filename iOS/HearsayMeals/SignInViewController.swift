//
//  SignInViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/11/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

private let kClientId = "966122623899-snf8rtjucf08hup8a2jjmihcina16a0j.apps.googleusercontent.com"
private let kDomain = "hearsaycorp.com"

private var kDomainErrorText = "Only Hearsay Social employees can use Hearsay Meals. Please log in with your \(kDomain) login."

class SignInViewController: UIViewController, GPPSignInDelegate {
    @IBOutlet weak var errorTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var signIn = GPPSignIn.sharedInstance()
        signIn.shouldFetchGooglePlusUser = true
        signIn.clientID = kClientId
        signIn.scopes = [ kGTLAuthScopePlusUserinfoEmail, kGTLAuthScopeCalendarReadonly ]
        signIn.delegate = self

        let success = signIn.trySilentAuthentication()
        NSLog("Silent Auth %s", success ? "successfull" : "failed")
        
//        // Test Parse
//        var testObject = PFObject(className: "TestObject")
////            objectWithClassName: "TestObject")
//        testObject["foo"] = "bar"
//        testObject.saveInBackground()
////        presentTabView() // TODO Comment this out
    }
    
    func finishedWithAuth (auth: GTMOAuth2Authentication,
        error: NSError?) {
            if (error != nil) {
                NSLog("Received error %@ and auth object %@", error!, auth)
                errorTextView.text = error?.localizedDescription
                errorTextView.hidden = false
            } else {
                var googlePlusUser = GPPSignIn.sharedInstance().googlePlusUser
                
                if (googlePlusUser.domain != kDomain) {
                    NSLog("Wrong domain: %@", googlePlusUser.domain)
                    errorTextView.text = kDomainErrorText
                    errorTextView.hidden = false
                    return
                }
                
                var userEmail = (googlePlusUser.emails[0] as GTLPlusPersonEmailsItem).value
                
                PFUser.logInWithUsernameInBackground(userEmail, password: kUserPassword, block: { (parseUser: PFUser!, error: NSError!) -> Void in
                    if (error != nil) {
                        NSLog("%@ does not exist in Parse", userEmail)
                        var name = googlePlusUser.nickname
                        if (name == nil) {
                            name = googlePlusUser.name.formatted
                        }
                        
                        var parseUser = PFUser()
                        parseUser.email = userEmail
                        parseUser.username = userEmail
                        parseUser[kUserNameKey] = name
                        
                        parseUser.signUpInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                            if (error == nil) {
                                NSLog("Received error %@ creating user", error)
                                self.errorTextView.text = error?.localizedDescription
                                self.errorTextView.hidden = false
                            } else {
                                self.presentTabView()
                            }
                        })
                    } else {
                        NSLog("%@ logged in to Parse successfully", userEmail)
                        self.presentTabView()
                    }
                })
            }
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
