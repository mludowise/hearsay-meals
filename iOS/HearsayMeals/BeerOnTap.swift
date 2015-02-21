//
//  BeerOnTap.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/20/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

final class BeerOnTap : CloudData {
    let id : String
    let beer : Beer
    let filled : NSDate
    let kickedReports : [UserInfo]
    
    required init(data: NSDictionary) {
        id = data["id"] as String
        beer = Beer(data: data["beer"] as NSDictionary)
        println(data["filled"])
        filled = data["filled"] as NSDate
        kickedReports = UserInfo.arrayFromData(data["kickedReports"] as [NSDictionary]?)
    }
    
    var data : RawCloudData {
        get {
            return [
                "id": id,
                "beer": beer.data,
                "filled": filled,
                "kickedReports": kickedReports
            ]
        }
    }
    
    class func arrayFromData(array: [NSDictionary]?) -> [BeerOnTap] {
        return CloudDataUtil.arrayFromData(array)
    }
    
    class func arrayToData(array: [BeerOnTap]) -> [RawCloudData] {
        return CloudDataUtil.arrayToData(array)
    }
}
