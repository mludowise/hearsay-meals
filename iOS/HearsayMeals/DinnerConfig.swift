//
//  DinnerConfig.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 2/20/15.
//  Copyright (c) 2015 Mel Ludowise. All rights reserved.
//

import Foundation

class DinnerConfig {
    let minPeople : Int
    let deadline : DinnerDeadline
    
    init(data: NSDictionary) {
        minPeople = data["minPeople"] as Int
        deadline = DinnerDeadline(data: data["deadline"] as NSDictionary)
    }
    
    init(minPeople: Int, deadlineHours: Int, deadlineMinutes: Int) {
        self.minPeople = minPeople
        deadline = DinnerDeadline(hours: deadlineHours, minutes: deadlineMinutes)
    }
    
    var data : [String : AnyObject] {
        get {
            return [
                "minPeople": minPeople,
                "deadline": deadline.data
            ]
        }
    }
}

class DinnerDeadline {
    let hours : Int
    let minutes : Int
    
    init(data: NSDictionary) {
        hours = data["hours"] as Int
        minutes = data["minutes"] as Int
    }
    
    init(hours: Int, minutes: Int) {
        self.hours = hours
        self.minutes = minutes
    }
    
    var data : [String : Int] {
        get {
            return [
                "hours": hours,
                "minutes": minutes
            ]
        }
    }
}