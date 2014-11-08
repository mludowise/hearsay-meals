//
//  CalendarViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/12/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

private let kTeamCalendarId = "hearsaycorp.com_b8edk8m1lmv57al9uiferecurk@group.calendar.google.com"
private let kLunchEventSummary = "Lunch Menu (see below)"
private let kCellReuseIdentifier = "calendarCell"
private var dateFormatter = NSDateFormatter()
private let kDayFormat = "EEE"
private let kDateFormat = "MMM d"

class CalendarTableViewCell : UITableViewCell {
    @IBOutlet var dayLabel: UILabel?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var descriptionLabel1: UILabel?
    @IBOutlet var descriptionLabel2: UILabel?
    @IBOutlet var descriptionLabel3: UILabel?
    
    func loadItem(#description: String, date: GTLDateTime) {
        // Breakup description onto 3 lines and filter out dietary restrictions
        var lines = description.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
        var matches = [String]()
        for line in lines {
            if (line != "") {
                var contents = line.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "*("))
                var text = contents[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                if (text != "") {
                    matches.append(text)
                }
            }
        }
        descriptionLabel1?.text = matches.count > 0 ? matches[0] : description
        descriptionLabel2?.text = matches.count > 1 ? matches[1] : ""
        descriptionLabel3?.text = matches.count > 2 ? matches[2] : ""
        
        dateFormatter.dateFormat = kDateFormat
        dateLabel?.text = dateFormatter.stringFromDate(date.date)
        
        dateFormatter.dateFormat = kDayFormat
        dayLabel?.text = dateFormatter.stringFromDate(date.date)
    }
}

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView?
    
    private var calendarService = GTLServiceCalendar()
    private var teamCalendarEvents : GTLCalendarEvents?
    private var calendarEventsServiceTicket : GTLServiceTicket?
    private var calendarEventsFetchError : NSError?
    private var lunchCalendarEvents = [GTLCalendarEvent]()

    override func viewDidLoad() {
        super.viewDidLoad()
        var nib = UINib(nibName: "CalendarTableViewCell", bundle: nil)
        tableView?.registerNib(nib, forCellReuseIdentifier: kCellReuseIdentifier)
        
        calendarService.shouldFetchNextPages = true
        calendarService.retryEnabled = true
        fetchCalendarEvents()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lunchCalendarEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:CalendarTableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier) as CalendarTableViewCell
        
        var event = lunchCalendarEvents[indexPath.row]
        cell.loadItem(description: event.descriptionProperty, date: event.start.dateTime)
        
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var lunchEventViewController = storyboard?.instantiateViewControllerWithIdentifier("lunchEventViewController") as LunchEventViewController!
        lunchEventViewController.calendarEvent = lunchCalendarEvents[indexPath.row]
        self.navigationController?.pushViewController(lunchEventViewController, animated: true)
    }

    func refreshTable(oldEvents:[GTLCalendarEvent]) {
        var paths = [NSIndexPath]()
        
        tableView?.beginUpdates()
        
        // Deletes
        for (index, event) in enumerate(oldEvents) {
            paths.append(NSIndexPath(forRow: index, inSection: 0))
        }
        tableView?.deleteRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        // Reloads
        
        // Inserts
        paths = [NSIndexPath]()
        for (index, event) in enumerate(lunchCalendarEvents) {
            paths.append(NSIndexPath(forRow: index, inSection: 0))
        }
        tableView?.insertRowsAtIndexPaths(paths, withRowAnimation: UITableViewRowAnimation.Automatic)
        tableView?.endUpdates()
    }
    
    func fetchCalendarEvents() {
        NSLog("Fetching calendar events")
        
        teamCalendarEvents = nil
        calendarEventsFetchError = nil
        
        var startOfDay = dateTimeForTodayAtHour(0,minute: 0,second: 0,timeZone: NSTimeZone(name: "US/Pacific")!)
        var query = GTLQueryCalendar.queryForEventsListWithCalendarId(kTeamCalendarId) as GTLQueryCalendar
        query.minAccessRole = kGTLCalendarMinAccessRoleReader
        query.maxResults = 10;
        query.timeMin = startOfDay
        calendarService.authorizer = GPPSignIn.sharedInstance().authentication
        calendarService.executeQuery(query,
            completionHandler: { (ticket:GTLServiceTicket!, events: AnyObject!, error:NSError!) in
                self.calendarEventsFetchError = error
                self.calendarEventsServiceTicket = nil
                
                if (error != nil) {
                    NSLog("No Calendar Found. Error: %@", error)
                } else {
                    self.teamCalendarEvents = events as? GTLCalendarEvents
                    var oldEvents = self.lunchCalendarEvents
                    self.lunchCalendarEvents = [GTLCalendarEvent]()
                    
                    var items = self.teamCalendarEvents!.items()
                    // TODO: Sort by date & filter out repeating events that are out of scope
//                    items.sort({ (event1, event2) -> Bool in
//                        return self.compareCalendarDates((event1 as GTLCalendarEvent), event2: (event2 as GTLCalendarEvent))
//                    })
                    
                    for item in items as NSArray {
                        var calendarEvent = item as GTLCalendarEvent
                        if (calendarEvent.summary != nil && calendarEvent.summary == kLunchEventSummary) {
                            self.lunchCalendarEvents.append(calendarEvent)
                        }
                    }
                    NSLog("Retreived %d lunch items.", self.lunchCalendarEvents.count)
                    self.refreshTable(oldEvents)
                }
        })
    }
    
    @IBAction func onRefreshButton(sender: AnyObject) {
        fetchCalendarEvents()
    }
    
    // Utility routine to make a GTLDateTime object for sometime today
    func dateTimeForTodayAtHour(hour: Int, minute: Int, second: Int, timeZone: NSTimeZone) -> GTLDateTime {
        let kComponentBits = (NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
            | NSCalendarUnit.CalendarUnitHour | NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond);
        
        var cal = NSCalendar(identifier: NSGregorianCalendar)
//        var dateComponents = cal.components(kComponentBits, fromDate:NSDate.date())
        var dateComponents = cal?.components(kComponentBits, fromDate: NSDate())
        dateComponents?.hour = hour
        dateComponents?.minute = minute
        dateComponents?.hour = hour
        dateComponents?.second = second
        dateComponents?.timeZone = timeZone
        
        var dateTime = GTLDateTime(dateComponents: dateComponents)
        return dateTime;
    }
    
    func compareCalendarDates(event1: GTLCalendarEvent, event2: GTLCalendarEvent) -> Bool {
        var date1 : NSDate = event1.start.dateTime.date
        var date2 : NSDate = event2.start.dateTime.date
        return date1.compare(date2) == NSComparisonResult.OrderedAscending
    }
}
