//
//  UserInfo.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/20/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

class UserInfo {
    let id : String
    let name : String
    let pictureURL : String
    let preferences : [Int]?
    let preferenceNote : String?
    
    init(data: NSDictionary) {
        id = data["id"] as String
        name = data["name"] as String
        pictureURL = data["picture"] as String
        preferences = data["preferences"] as [Int]?
        preferenceNote = data["preferenceNote"] as String?
    }
    
    var data : [String : AnyObject?] {
        get {
            return [
                "id": id,
                "name": name,
                "picture": pictureURL,
                "preferences": preferences,
                "preferenceNote": preferenceNote
            ]
        }
    }
}
