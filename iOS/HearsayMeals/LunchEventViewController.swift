//
//  LunchEventViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/13/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

class LunchEventViewController: UIViewController {
    @IBOutlet weak var menuTextView: UITextView?
    
    private var dateFormatter = NSDateFormatter()
    private let kDayFormat = "EEE"
    
    var calendarEvent : GTLCalendarEvent?

    override func viewDidLoad() {
        super.viewDidLoad()
        menuTextView?.text = calendarEvent == nil ? "" : calendarEvent?.descriptionProperty
        var start = calendarEvent?.start.dateTime.date
        self.title = NSDateFormatter.localizedStringFromDate(start!, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.NoStyle)
    }
}
