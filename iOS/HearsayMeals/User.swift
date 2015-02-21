//
//  User.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/20/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

extension PFUser {
    var admin : Bool {
        get {
            return self["admin"] as Bool
        }
    }
    
    var name : String {
        get {
            return self["name"] as String
        }
    }
    
    var pictureURL : String {
        get {
            return self["picture"] as String
        }
    }
    
    var preferences : [Int]? {
        get {
            return self["preferences"] as [Int]?
        }
    }
    
    var preferenceNote : String? {
        get {
            return self["preference_note"] as String?
        }
    }
}