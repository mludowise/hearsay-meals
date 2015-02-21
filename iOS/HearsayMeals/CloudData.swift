//
//  CloudData.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/21/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation


typealias RawCloudData = [String : AnyObject]

protocol CloudData {
    init(data: NSDictionary)
    var data : RawCloudData { get }
    class func arrayToData(array: [Self]) -> [RawCloudData]
    class func arrayFromData(array: [NSDictionary]?) -> [Self]
}

internal class CloudDataUtil {
    class func arrayToData<T: CloudData>(array: [T]) -> [RawCloudData] {
        var result = [RawCloudData]()
        for item in array {
            result.append(item.data)
        }
        return result
    }
    
    class func arrayFromData<T: CloudData>(array: [NSDictionary]?) -> [T] {
        if (array == nil) {
            return []
        }
        
        var result = [T]()
        for data in array! {
            result.append(T(data: data))
        }
        return result
    }
    
    class func empty() -> RawCloudData {
        return [:]
    }
}

final class IdData : CloudData {
    let id : String
    
    init(data: NSDictionary) {
        id = data["id"] as String
    }
    
    init(id: String) {
        self.id = id
    }
    
    var data : RawCloudData {
        get {
            return [
                "id": id
            ]
        }
    }
    
    class func arrayFromData(array: [NSDictionary]?) -> [IdData] {
        return CloudDataUtil.arrayFromData(array)
    }
    
    class func arrayToData(array: [IdData]) -> [RawCloudData] {
        return CloudDataUtil.arrayToData(array)
    }
}