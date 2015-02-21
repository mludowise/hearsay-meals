//
//  ApplicationProperty.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/19/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

class ApplicationProperty {
    let version: Float
    let url: String
    
    init(data: NSDictionary) {
        version = data["version"] as Float
        url = data["url"] as String
    }
    
    var data : [String : AnyObject] {
        get {
            return [
                "version": version,
                "url": url
            ]
        }
    }
}

class ApplicationPlatform {
    let platform : String
    
    init(platform: String) {
        self.platform = platform
    }
    
    init () {
        self.platform = "iOS"
    }
    
    var data : [String : String] {
        get {
            return [
                "platform" : platform
            ]
        }
    }
}