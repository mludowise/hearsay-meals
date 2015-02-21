//
//  UserInfo.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/20/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

final class UserInfo : CloudData {
    let id : String
    let name : String
    let pictureURL : String
    let preferences : [Int]
    let preferenceNote : String?
    
    required init(data: NSDictionary) {
        id = data["id"] as String
        name = data["name"] as String
        pictureURL = data["picture"] as String
        preferences = data["preferences"] == nil ? [] : data["preferences"] as [Int]
        preferenceNote = data["preferenceNote"] as String?
    }
    
    init(user: PFUser) {
        id = user.objectId
        name = user.name
        pictureURL = user.pictureURL
        preferences = user.preferences
        preferenceNote = user.preferenceNote
    }
    
    var data : RawCloudData {
        get {
            var result : RawCloudData = [
                "id": id,
                "name": name,
                "picture": pictureURL,
                "preferences": preferences
            ]
            
            if (preferenceNote != nil) {
                result["preferenceNote"] = preferenceNote!
            }
            
            return result
        }
    }
    
    class func arrayToData(array: [UserInfo]) -> [RawCloudData] {
        return CloudDataUtil.arrayToData(array)
    }
    
    class func arrayFromData(array: [NSDictionary]?) -> [UserInfo] {
        return CloudDataUtil.arrayFromData(array)
    }
    
    class func findUser(users: [UserInfo], user: PFUser) -> Int? {
        for (index, u) in enumerate(users) {
            if (u.id == user.objectId) {
                return index
            }
        }
        return nil
    }
}
