//
//  LunchEventViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/13/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

let kLunchEventViewController = "lunchEventViewController"

class LunchEventViewController: UIViewController {
    @IBOutlet weak var menuTextView: UITextView?
    
    private var dateFormatter = NSDateFormatter()
    private let kDayFormat = "EEE"
    
    var calendarEvent : GTLCalendarEvent?

    override func viewDidLoad() {
        super.viewDidLoad()
        menuTextView?.text = calendarEvent == nil ? "" : calendarEvent?.descriptionProperty
        
        println("CalendarEvent: \(calendarEvent)")
        println("start: \(calendarEvent?.start)")
        println("datetime: \(calendarEvent?.start.dateTime)")
        println("date: \(calendarEvent?.start.dateTime.date)")

        var start = calendarEvent?.start.dateTime.date
        self.title = NSDateFormatter.localizedStringFromDate(start!, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    @IBAction func onSwipe(sender: UISwipeGestureRecognizer) {
        
    }
}
