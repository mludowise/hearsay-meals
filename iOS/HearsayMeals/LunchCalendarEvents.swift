//
//  WeekCalendarModel.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 1/19/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import UIKit

class LunchCalendarEvents: NSObject {
    private var eventsByWeek : [(week: Int, events:[GTLCalendarEvent])] = []
    private var sunday = pastSunday(NSDate())
    
    init(events: [GTLCalendarEvent]?, filter: (GTLCalendarEvent -> Bool)?) {
        if (events == nil) {
            return
        }
        
        // Group by weeks
        var eventsGroupedByWeek = [Int: [GTLCalendarEvent]]()
        for event in events! {
            if (filter == nil || filter!(event)) {
                var timeSinceSunday = event.start.dateTime.date.timeIntervalSinceDate(sunday)
                
                var week = convertToWeeks(timeSinceSunday)
                if (eventsGroupedByWeek[week] == nil) {
                    eventsGroupedByWeek[week] = []
                }
                eventsGroupedByWeek[week]!.append(event)
            }
        }
        
        // Sort weeks
        var weeks = eventsGroupedByWeek.keys.array
        weeks.sort({ (a: Int, b: Int) -> Bool in
            return a < b
        })
        
        // Convert to array
        for week in weeks {
            var group = eventsGroupedByWeek[week]!
            group.sort({ (event1: GTLCalendarEvent, event2: GTLCalendarEvent) -> Bool in
                var date1 = event1.start.dateTime.date
                var date2 = event2.start.dateTime.date
                return date2.timeIntervalSinceDate(date1) > 0
            })
            eventsByWeek += [(week: week as Int, events: group)]
        }
    }
    
    func numberOfWeeks() -> Int {
        return eventsByWeek.count
    }
    
    func numberOfEventsForWeek(weekIndex: Int) -> Int {
        return eventsByWeek[weekIndex].events.count
    }
    
    func numberOfEvents() -> Int {
        var total = 0
        for week in eventsByWeek {
            total += week.events.count
        }
        return total
    }
    
    func numberOfWeeksAway(weekIndex: Int) -> Int {
        return eventsByWeek[weekIndex].week
    }
    
    func getEvent(weekIndex: Int, eventInWeek: Int) -> GTLCalendarEvent {
        return eventsByWeek[weekIndex].events[eventInWeek]
    }
    
    func getEvent(index: LunchIndex) -> GTLCalendarEvent {
        return getEvent(index.weekIndex, eventInWeek: index.eventInWeek)
    }
    
    func nextIndex(index: LunchIndex) -> LunchIndex? {
        if (!validIndex(index)) {
            return nil
        }
        
        var weekIndex = index.weekIndex
        var eventInWeek = index.eventInWeek + 1
        
        if (eventInWeek >= numberOfEventsForWeek(weekIndex)) {
            eventInWeek = 0
            weekIndex++
            if (weekIndex >= numberOfWeeks()) {
                return nil
            }
        }
        
        return LunchIndex(weekIndex: weekIndex, eventInWeek: eventInWeek)
    }
    
    func previousIndex(index: LunchIndex) -> LunchIndex? {
        if (!validIndex(index)) {
            return nil
        }
        
        var weekIndex = index.weekIndex
        var eventInWeek = index.eventInWeek - 1
        
        if (eventInWeek < 0) {
            weekIndex--
            if (weekIndex < 0) {
                return nil
            }
            eventInWeek = numberOfEventsForWeek(weekIndex) - 1
        }
        
        return LunchIndex(weekIndex: weekIndex, eventInWeek: eventInWeek)
    }
    
    private func validIndex(index: LunchIndex) -> Bool {
        return (index.weekIndex >= 0 && index.weekIndex < numberOfWeeks())
            && (index.eventInWeek >= 0 && index.eventInWeek < numberOfEventsForWeek(index.weekIndex))
    }
    
    private func isEventOrderedBefore(event1: GTLCalendarEvent, event2: GTLCalendarEvent) -> Bool {
        var date1 = event1.start.dateTime.date
        var date2 = event2.start.dateTime.date
        return date2.timeIntervalSinceDate(date1) > 0
    }
}

class LunchIndex : NSObject {
    private var weekIndex : Int
    private var eventInWeek : Int
    
    init(weekIndex: Int, eventInWeek: Int) {
        self.weekIndex = weekIndex
        self.eventInWeek = eventInWeek
    }
}
