//
//  DateUtil.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 1/18/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

let kCalendarComponentBits = (NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
    | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond)

private var dateFormatter = NSDateFormatter()
private let kDayFormat = "EEE"
private let kDateFormat = "MMM d"

func dateTimeAtHour(date: NSDate, hour: Int, minute: Int, second: Int, offsetYear: Int, offsetMonth: Int, offsetDay: Int, offsetHour: Int, offsetMinute: Int, offsetSecond:Int) -> NSDate {
    return dateTimeAtHour(date, hour, minute, second, nil, offsetYear, offsetMonth, offsetDay, offsetHour, offsetMinute, offsetSecond)
}

func dateTimeAtHour(date: NSDate, hour: Int, minute: Int, second: Int, timeZone: NSTimeZone?, offsetYear: Int, offsetMonth: Int, offsetDay: Int, offsetHour: Int, offsetMinute: Int, offsetSecond:Int) -> NSDate {
    var cal = NSCalendar(identifier: NSGregorianCalendar)!
    var dateComponents = cal.components(kCalendarComponentBits, fromDate: date)
    var newDate = cal.dateBySettingHour(hour, minute: minute, second: second, ofDate: date, options: nil)!
    
    dateComponents = NSDateComponents()
    dateComponents.timeZone = timeZone?
    dateComponents = NSDateComponents()
    dateComponents.year = offsetYear
    dateComponents.month = offsetMonth
    dateComponents.day = offsetDay
    dateComponents.hour = offsetHour
    dateComponents.minute = offsetMinute
    dateComponents.second = offsetSecond
    return cal.dateByAddingComponents(dateComponents, toDate: newDate, options: nil)!
}

func todayAtZero(timeZone: NSTimeZone?) -> NSDate {
    return dateTimeAtHour(NSDate(), 0, 0, 0, timeZone, 0, 0, 0, 0, 0, 0)
}

func tomorrowAtZero(timeZone: NSTimeZone?) -> NSDate {
    return dateTimeAtHour(NSDate(), 0, 0, 0, timeZone, 0, 0, 1, 0, 0, 0)
}

func daysInFutureAtZero(days: Int, timeZone: NSTimeZone?) -> NSDate {
    return dateTimeAtHour(NSDate(), 0, 0, 0, timeZone, 0, 0, days, 0, 0, 0)
}

func pastSunday(date: NSDate) -> NSDate {
    var cal = NSCalendar(identifier: NSGregorianCalendar)!
    var dateComponents = cal.components(NSCalendarUnit.WeekdayCalendarUnit, fromDate: date)
    var weekday = dateComponents.weekday
    
    // Set to midnight
    var newDate = cal.dateBySettingHour(0, minute: 0, second: 0, ofDate: date, options: nil)!
    
    dateComponents = NSDateComponents()
    dateComponents.day = -weekday
    return cal.dateByAddingComponents(dateComponents, toDate: newDate, options: nil)!
}

func timeUntil(hour: Int, minute: Int) -> NSTimeInterval {
    var date = dateTimeAtHour(NSDate(), hour, minute, 0, 0, 0, 0, 0, 0, 0)
    return date.timeIntervalSinceNow
}

func convertToWeeks(timeInterval: NSTimeInterval) -> Int {
    return Int(timeInterval / 604800)    //(7 * 24 * 60 * 60)
}
