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
    
    var lunchEvents : [GTLCalendarEvent]?
    var currentLunchIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var calendarEvent = lunchEvents?[currentLunchIndex]
        
        menuTextView?.text = calendarEvent == nil ? "" : calendarEvent?.descriptionProperty
        
        println("CalendarEvent: \(calendarEvent)")
        println("start: \(calendarEvent?.start)")
        println("datetime: \(calendarEvent?.start.dateTime)")
        println("date: \(calendarEvent?.start.dateTime.date)")

        var start = calendarEvent?.start.dateTime.date
        self.title = NSDateFormatter.localizedStringFromDate(start!, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
    
    @IBAction func onSwipe(sender: UISwipeGestureRecognizer) {
        // If there is another lunch menu to swipe through...
        
        // Copy this view & fill in the data for the next menu item
        
        // Initialize at the off to the left or right of the screen
        
        // Animate both views moving together to the left or right
    }
}
