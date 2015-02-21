//
//  ApplicationProperty.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/19/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

final class ApplicationProperty : CloudData {
    let version: Float
    let url: String
    
    required init(data: NSDictionary) {
        version = data["version"] as Float
        url = data["url"] as String
    }
    
    var data : RawCloudData {
        get {
            return [
                "version": version,
                "url": url
            ]
        }
    }
    
    class func arrayToData(array: [ApplicationProperty]) -> [RawCloudData] {
        return CloudDataUtil.arrayToData(array)
    }
    
    class func arrayFromData(array: [NSDictionary]?) -> [ApplicationProperty] {
        return CloudDataUtil.arrayFromData(array)
    }
}

final class ApplicationPlatform : CloudData {
    let platform : String
    
    required init(data: NSDictionary) {
        self.platform = data["platform"] as String
    }
    
    init(platform: String) {
        self.platform = platform
    }
    
    init () {
        self.platform = "iOS"
    }
    
    var data : RawCloudData {
        get {
            return [
                "platform" : platform
            ]
        }
    }
    
    class func arrayToData(array: [ApplicationPlatform]) -> [RawCloudData] {
        return CloudDataUtil.arrayToData(array)
    }
    
    class func arrayFromData(array: [NSDictionary]?) -> [ApplicationPlatform] {
        return CloudDataUtil.arrayFromData(array)
    }
}