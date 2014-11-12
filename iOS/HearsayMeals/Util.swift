//
//  Util.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/8/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import Foundation

let kOfficeTimeZone = NSTimeZone(name: "US/Pacific")!
let kCalendarComponentBits = (NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
    | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond)

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func dateTimeAtHour(date: NSDate, hour: Int, minute: Int, second: Int, timeZone: NSTimeZone, offsetYear: Int, offsetMonth: Int, offsetDay: Int, offsetHour: Int, offsetMinute: Int, offsetSecond:Int) -> NSDate {
    var cal = NSCalendar(identifier: NSGregorianCalendar)!
    var dateComponents = cal.components(kCalendarComponentBits, fromDate: date)
    dateComponents.timeZone = timeZone
    var newDate = cal.dateBySettingHour(hour, minute: minute, second: second, ofDate: date, options: nil)!
    
    dateComponents = NSDateComponents()
    dateComponents.year = offsetYear
    dateComponents.month = offsetMonth
    dateComponents.day = offsetDay
    dateComponents.hour = offsetHour
    dateComponents.minute = offsetMinute
    dateComponents.second = offsetSecond
    return cal.dateByAddingComponents(dateComponents, toDate: newDate, options: nil)!
}

func todayAtZero(timeZone: NSTimeZone) -> NSDate {
    return dateTimeAtHour(NSDate(), 0, 0, 0, timeZone, 0, 0, 0, 0, 0, 0)
}

func tomorrowAtZero(timeZone: NSTimeZone) -> NSDate {
    return dateTimeAtHour(NSDate(), 0, 0, 0, timeZone, 0, 0, 1, 0, 0, 0)
}