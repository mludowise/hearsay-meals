//
//  CalendarViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/12/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

private let kCellReuseIdentifier = "LunchCalendarTableCell"

class CalendarViewController: UITableViewController {
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emptyView: UIView!
    
    private var calendarService = GTLServiceCalendar()
    private var teamCalendarEvents : GTLCalendarEvents?
    private var calendarEventsServiceTicket : GTLServiceTicket?
    private var calendarEventsFetchError : NSError?
    
    private var lunchCalendarEvents : LunchCalendarEvents?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Back button on the next viewController should have no title
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: self, action: "back")
        
        calendarService.shouldFetchNextPages = true
        calendarService.retryEnabled = true
        fetchCalendarEvents { () -> Void in
            self.tableView.tableHeaderView = nil
            self.updateEmptyView()
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView?) -> Int {
        return lunchCalendarEvents == nil ? 0 : lunchCalendarEvents!.numberOfWeeks()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lunchCalendarEvents == nil ? 0 : lunchCalendarEvents!.numberOfEventsForWeek(section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier) as LunchCalendarTableCell
        
        var event = lunchCalendarEvents!.getEvent(indexPath.section, eventInWeek: indexPath.row)
        cell.loadItem(description: event.descriptionProperty, date: event.start.dateTime)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var lunchEventViewController = storyboard?.instantiateViewControllerWithIdentifier(kLunchEventViewController) as LunchEventViewController!
        lunchEventViewController.initializeView(lunchCalendarEvents!, currentLunchIndex: LunchIndex(weekIndex: indexPath.section, eventInWeek: indexPath.row))

        self.navigationController?.pushViewController(lunchEventViewController, animated: true)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var week = lunchCalendarEvents!.numberOfWeeksAway(section)
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
                    NSLog("No Calendar Found. Error: \(error)")
                } else {
                    self.teamCalendarEvents = events as? GTLCalendarEvents
                    var oldEvents = self.lunchCalendarEvents

                    var events = self.teamCalendarEvents!.items() as [GTLCalendarEvent]
                    self.lunchCalendarEvents = LunchCalendarEvents(events: events, filter: self.showLunchEvent)
                    
                    NSLog("Retreived \(self.lunchCalendarEvents!.numberOfEvents()) lunch items.")
                    completion?()
                    self.tableView?.reloadData()
                }
        })
    }
    
    private func updateEmptyView() {
        emptyView.hidden = lunchCalendarEvents?.numberOfEvents() > 0
    }
    
    private func showLunchEvent(event: GTLCalendarEvent) -> Bool {
        return event.summary? == "Lunch Menu (see below)"
            && event.recurringEventId != nil
            && event.descriptionProperty? != "TBA"
            && !(event.descriptionProperty =~ "^Allergen Key:.*(\r|\n)*TBA$")
            && !(event.descriptionProperty =~ "^TBA(\r|\n)*Allergen Key:.*$")
            && !(event.descriptionProperty =~ "^Key\\:(\r|\n)(\\w .+?(\r|\n){0,1})*$")
    }
    
    @IBAction func onRefresh(sender: UIRefreshControl) {
        fetchCalendarEvents { () -> Void in
            sender.endRefreshing()
            self.updateEmptyView()
        }
    }
}
