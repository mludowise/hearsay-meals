//
//  Beer.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/21/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

final class Beer: CloudData {
    let name : String
    
    required init(data: NSDictionary) {
        name = data["name"] as String
    }
    
    init(name: String) {
        self.name = name
    }
    
    var data : RawCloudData {
        get {
            return [
                "name": name
            ]
        }
    }
    
    class func arrayFromData(array: [NSDictionary]?) -> [Beer] {
        return CloudDataUtil.arrayFromData(array)
    }
    
    class func arrayToData(array: [Beer]) -> [RawCloudData] {
        return CloudDataUtil.arrayToData(array)
    }
}