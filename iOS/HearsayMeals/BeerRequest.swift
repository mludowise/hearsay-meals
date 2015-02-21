//
//  BeerRequest.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/21/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

final class BeerRequest : CloudData {
    let id : String
    let beer : Beer
    let votes : [UserInfo]
    
    required init(data: NSDictionary) {
        self.id = data["id"] as String
        beer = Beer(data: data["beer"] as NSDictionary)
        votes = UserInfo.arrayFromData(data["votes"] as [NSDictionary]?)
    }
    
    init(id: String, beer: Beer, requestor: PFUser) {
        self.id = id
        self.beer = beer
        votes = [UserInfo(user: requestor)]
    }
    
    var data : RawCloudData {
        get {
            return [
                "id": id,
                "beer": beer,
                "votes": votes
            ]
        }
    }
    
    class func arrayFromData(array: [NSDictionary]?) -> [BeerRequest] {
        return CloudDataUtil.arrayFromData(array)
    }
    
    class func arrayToData(array: [BeerRequest]) -> [RawCloudData] {
        return CloudDataUtil.arrayToData(array)
    }
    
    class func findRequest(array: [BeerRequest], request: BeerRequest) -> Int? {
        for (index, r) in enumerate(array) {
            if (r.id == request.id) {
                return index
            }
        }
        return nil
    }
}
