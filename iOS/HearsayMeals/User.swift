//
//  User.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/20/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

extension PFUser {
    class func password() -> String{
        return "password"
    }
    
    var admin : Bool {
        get {
            return self["admin"] as Bool
        }
    }
    
    var name : String {
        get {
            return self["name"] as String
        }
        set(name) {
            self["name"] = name
        }
    }
    
    var pictureURL : String {
        get {
            return self["picture"] as String
        }
        set(pictureURL) {
            self["picture"] = pictureURL
        }
    }
    
    var preferences : [Int] {
        get {
            return self["preferences"] == nil ? [0] : self["preferences"] as [Int]
        }
    }
    
    var preferenceNote : String? {
        get {
            return self["preference_note"] as String?
        }
        set(preferenceNote) {
            self["preference_note"] = preferenceNote
        }
    }
    
    func addPreference(preference: Int) {
        addUniqueObject(preference, forKey: "preferences")
    }
    
    func removePreference(preference: Int) {
        removeObject(preference, forKey: "preferences")
    }
    
    func updatePreferences(addPreferences: [Int], removePreferences: [Int]) {
        var preferences = self.preferences
        
        for preference in removePreferences {
            let index = find(preferences, preference)
            if (index != nil) {
                preferences.removeAtIndex(index!)
            }
        }
        
        for preference in addPreferences {
            let index = find(preferences, preference)
            if (index == nil) {
                preferences.append(preference)
            }
        }
        self["preferences"] = preferences
        saveInBackground()
    }
}