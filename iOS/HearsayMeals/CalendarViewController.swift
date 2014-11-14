//
//  CalendarViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/12/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

private let kCellReuseIdentifier = "LunchCalendarTableCell"


private let kTeamCalendarId = "hearsaycorp.com_b8edk8m1lmv57al9uiferecurk@group.calendar.google.com"
private let kLunchEventSummary = "Lunch Menu (see below)"
private let kGenericLunchEventDescription = "TBA"

private var dateFormatter = NSDateFormatter()
private let kDayFormat = "EEE"
private let kDateFormat = "MMM d"

class LunchCalendarTableCell : UITableViewCell {
    @IBOutlet var dayLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var descriptionLabel1: UILabel!
    @IBOutlet var descriptionLabel2: UILabel!
    @IBOutlet var descriptionLabel3: UILabel!
    
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
        descriptionLabel1.text = matches.count > 0 ? matches[0] : description
        descriptionLabel2.text = matches.count > 1 ? matches[1] : ""
        descriptionLabel3.text = matches.count > 2 ? matches[2] : ""
        
        dateFormatter.dateFormat = kDateFormat
        dateLabel.text = dateFormatter.stringFromDate(date.date)
        
        dateFormatter.dateFormat = kDayFormat
        dayLabel.text = dateFormatter.stringFromDate(date.date)
    }
}

class CalendarViewController: UITableViewController {
    private var calendarService = GTLServiceCalendar()
    private var teamCalendarEvents : GTLCalendarEvents?
    private var calendarEventsServiceTicket : GTLServiceTicket?
    private var calendarEventsFetchError : NSError?
    private var lunchCalendarEvents : [(week: Int, events:[GTLCalendarEvent])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        calendarService.shouldFetchNextPages = true
        calendarService.retryEnabled = true
        fetchCalendarEvents(nil)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return lunchCalendarEvents.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lunchCalendarEvents[section].events.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier) as LunchCalendarTableCell
        
        var event = lunchCalendarEvents[indexPath.section].events[indexPath.row]
        cell.loadItem(description: event.descriptionProperty, date: event.start.dateTime)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var lunchEventViewController = storyboard?.instantiateViewControllerWithIdentifier(kLunchEventViewController) as LunchEventViewController!
        lunchEventViewController.calendarEvent = lunchCalendarEvents[indexPath.section].events[indexPath.row]
        self.navigationController?.pushViewController(lunchEventViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var week = lunchCalendarEvents[section].week
        switch (week) {
        case 0:
            return "This Week"
        case 1:
            return "Next Week"
        default:
            return "In \(week) Weeks"
        }
    }
    
    func fetchCalendarEvents(completion: (() -> Void)?) {
        NSLog("Fetching calendar events")
        
        teamCalendarEvents = nil
        calendarEventsFetchError = nil
        
        var sunday = pastSunday(NSDate())
        var startOfDay = GTLDateTime(date: todayAtZero(kOfficeTimeZone), timeZone: kOfficeTimeZone)
        var inTwoWeeks = GTLDateTime(date: daysInFutureAtZero(14, kOfficeTimeZone), timeZone: kOfficeTimeZone)
        var query = GTLQueryCalendar.queryForEventsListWithCalendarId(kTeamCalendarId) as GTLQueryCalendar
        query.minAccessRole = kGTLCalendarMinAccessRoleReader
        query.maxResults = 10
        query.timeMin = startOfDay
        query.timeMax = inTwoWeeks
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
                    self.lunchCalendarEvents = []
                    
                    var eventsGroupedByWeek = [Int: [GTLCalendarEvent]]()
                    
                    var items = self.teamCalendarEvents!.items()
                    for item in items as NSArray {
                        var calendarEvent = item as GTLCalendarEvent
                        
                        // Is a lunch item & not a generic "TBA" lunch
                        if (calendarEvent.summary == kLunchEventSummary && calendarEvent.descriptionProperty != kGenericLunchEventDescription) {
                            var timeSinceSunday = calendarEvent.start.dateTime.date.timeIntervalSinceDate(sunday)
                            
                            var week = convertToWeeks(timeSinceSunday)
                            if (eventsGroupedByWeek[week] == nil) {
                                eventsGroupedByWeek[week] = []
                            }
                            eventsGroupedByWeek[week]!.append(calendarEvent)
                        }
                    }
                    
                    self.addLunchEvents(eventsGroupedByWeek)
                    
                    NSLog("Retreived %d lunch items.", self.lunchCalendarEvents.count)
                    self.tableView?.reloadData()
                    
                    completion?()
                }
        })
    }
    @IBAction func onRefresh(sender: UIRefreshControl) {
        fetchCalendarEvents { () -> Void in
            sender.endRefreshing()
        }
    }
    
    private func addLunchEvents(eventsGroupedByWeek: [Int: [GTLCalendarEvent]]) {
        var weeks = eventsGroupedByWeek.keys.array
        weeks.sort({ (a: Int, b: Int) -> Bool in
            return a < b
        })
        
        for week in weeks {
            var group = eventsGroupedByWeek[week]!
            group.sort(self.isEventOrderedBefore)
            self.lunchCalendarEvents += [(week: week as Int, events: group)]
        }
    }
    
    private func isEventOrderedBefore(event1: GTLCalendarEvent, event2: GTLCalendarEvent) -> Bool {
        var date1 = event1.start.dateTime.date
        var date2 = event2.start.dateTime.date
        return date2.timeIntervalSinceDate(date1) > 0
    }
}
