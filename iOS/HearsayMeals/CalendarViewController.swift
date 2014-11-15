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

class CalendarViewController: UITableViewController {
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var calendarService = GTLServiceCalendar()
    private var teamCalendarEvents : GTLCalendarEvents?
    private var calendarEventsServiceTicket : GTLServiceTicket?
    private var calendarEventsFetchError : NSError?
    private var lunchCalendarEvents : [(week: Int, events:[GTLCalendarEvent])] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Back button on the next viewController should have no title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "back")
        
        calendarService.shouldFetchNextPages = true
        calendarService.retryEnabled = true
        fetchCalendarEvents { () -> Void in
            self.tableView.tableHeaderView = nil
//            UIView.animateWithDuration(1, animations: { () -> Void in
//                self.activityIndicator.frame.origin.y = -self.loadingView.frame.height
//                self.tableView.tableHeaderView?.frame.size.height = 0
//            }, completion: { (Bool) -> Void in
//                self.tableView.tableHeaderView = nil
//            })
        }
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
        var event = lunchCalendarEvents[indexPath.section].events[indexPath.row]
        
        var flattenedEventList = flattenCalendarEvents(lunchCalendarEvents, indexPath: indexPath)
        lunchEventViewController.initializeView(flattenedEventList.events, currentLunchIndex: flattenedEventList.index)

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
                    completion?()
                    self.tableView?.reloadData()
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
    
    private func flattenCalendarEvents(calendarEvents: [(week: Int, events:[GTLCalendarEvent])], indexPath: NSIndexPath) -> (events: [GTLCalendarEvent], index: Int) {
        var events = [GTLCalendarEvent]()
        var index = 0
        for (section, group) in enumerate(lunchCalendarEvents) {
            events += group.events
            if (indexPath.section < section) {
                index += group.events.count
            } else if (indexPath.section == section) {
                index += indexPath.row
            }
        }
        return (events: events, index: index)
    }
}
