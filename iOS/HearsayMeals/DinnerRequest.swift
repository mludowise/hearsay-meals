//
//  DinnerRequest.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/21/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

final class DinnerRequest : CloudData {
    let dateParam : DateParam
    let specialRequest : String?
    
    required init(data: NSDictionary) {
        dateParam = DateParam(data: data["date"] as NSDictionary)
        specialRequest = data["specialRequest"] as String?
    }
    
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
    
    var data : RawCloudData {
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
    
    class func arrayToData(array: [DinnerRequest]) -> [RawCloudData] {
        return CloudDataUtil.arrayToData(array)
    }
    
    class func arrayFromData(array: [NSDictionary]?) -> [DinnerRequest] {
        return CloudDataUtil.arrayFromData(array)
    }
}

final class DateParam : CloudData {
    private let calendarUnits = NSCalendarUnit.DayCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.YearCalendarUnit
    let date : NSDate
    
    required init(data: NSDictionary) {
        let components = NSCalendar.currentCalendar().components(
            calendarUnits,
            fromDate: NSDate())
        components.year = data["year"] as Int
        components.month = data["month"] as Int + 1
        components.day = data["day"] as Int
        date = NSDate()
    }
    
    init(date: NSDate) {
        self.date = date
    }
    
    var data : RawCloudData {
        get {
            let components = NSCalendar.currentCalendar().components(
                calendarUnits,
                fromDate: date)
            return [
                "year": components.year,
                "month": components.month - 1,
                "day": components.day
            ]
        }
    }
    
    class func arrayToData(array: [DateParam]) -> [RawCloudData] {
        return CloudDataUtil.arrayToData(array)
    }
    
    class func arrayFromData(array: [NSDictionary]?) -> [DateParam] {
        return CloudDataUtil.arrayFromData(array)
    }
}
