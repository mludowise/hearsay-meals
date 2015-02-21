//
//  DinnerOrder.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/19/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

class DinnerOrder {
    let specialRequest : String?
    let userInfo : UserInfo
    
    init(data: NSDictionary) {
        specialRequest = data["specialRequest"] as String?
        userInfo = UserInfo(data: data["user"] as NSDictionary)
    }
    
    var data : [String : AnyObject] {
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
    
    class func dinnerOrders(array: [NSDictionary]) -> [DinnerOrder] {
        var orders = [DinnerOrder]()
        for data in array {
            orders.append(DinnerOrder(data: data))
        }
        return orders
    }
}

class DinnerRequest {
    let dateParam : DateParam
    let specialRequest : String?
    
    init(date: NSDate, specialRequest: String?) {
        dateParam = DateParam(date: date)
        self.specialRequest = specialRequest
    }
    
    init(date: NSDate) {
        dateParam = DateParam(date: date)
    }
    
    var date : NSDate {
        get {
            return dateParam.date
        }
    }
    
    var data : [String : AnyObject] {
        get {
            var result : [String : AnyObject] = [
                "date": dateParam.data
            ]
            
            if (specialRequest != nil) {
                result["specialRequest"] = specialRequest
            }

            return result
        }
    }
}

class DateParam {
    let date : NSDate
    
    init(date: NSDate) {
        self.date = date
    }
    
    var data : [String : Int] {
        get {
            let components = NSCalendar.currentCalendar().components(
                NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit,
                fromDate: date)
            return [
                "year": components.year,
                "month": components.month - 1,
                "day": components.day
            ]
        }
    }
}
