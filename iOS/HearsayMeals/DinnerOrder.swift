//
//  DinnerOrder.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/19/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

final class DinnerOrder : CloudData {
    let specialRequest : String?
    let userInfo : UserInfo
    
    init(data: NSDictionary) {
        specialRequest = data["specialRequest"] as String?
        userInfo = UserInfo(data: data["user"] as NSDictionary)
    }
    
    var data : RawCloudData {
        get {
            var result : [String : AnyObject] = [
                "user": userInfo
            ]
            
            if (specialRequest != nil) {
                result["specialRequest"] = specialRequest
            }
            return result
        }
    }
    
    class func arrayToData(array: [DinnerOrder]) -> [RawCloudData] {
        return CloudDataUtil.arrayToData(array)
    }
    
    class func arrayFromData(array: [NSDictionary]?) -> [DinnerOrder] {
        return CloudDataUtil.arrayFromData(array)
    }
}