//
//  LunchEventViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/13/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

let kLunchEventViewController = "lunchEventViewController"
private let kDateFormat = "EEEE, MMM d"

class LunchEventViewController: UIViewController {
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuTextView: UITextView!
    
    // To format date in title
    private var dateFormatter = NSDateFormatter()
    
    // Needed for swipe animation
    private var menuCopy: UIView?
    private var nextIndex: LunchIndex?

    // These should be set when the view is instantiated
    private var lunchEvents : LunchCalendarEvents?
    private var currentLunchIndex = LunchIndex(weekIndex: 0, eventInWeek: 0)
    
    internal func initializeView(lunchEvents: LunchCalendarEvents, currentLunchIndex: LunchIndex) {
        self.lunchEvents = lunchEvents
        self.currentLunchIndex = currentLunchIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateFormat = kDateFormat
        updateView()
        updateTitle(currentLunchIndex)
    }
    
    private func updateTitle(forIndex: LunchIndex) {
        var calendarEvent = lunchEvents?.getEvent(forIndex)
        var start = calendarEvent?.start.dateTime.date
        title = start == nil ? "" : dateFormatter.stringFromDate(start!)
    }
    
    private func updateView() {
        var calendarEvent = lunchEvents?.getEvent(currentLunchIndex)
        menuTextView.text = calendarEvent?.descriptionProperty
    }
    
    private func createMenuViewCopy(calendarEvent: GTLCalendarEvent) -> UIView {
        var menuCopy = UIView(frame: menuView.frame)
        menuCopy.backgroundColor = menuView.backgroundColor
        var menuTextCopy = NSKeyedUnarchiver.unarchiveObjectWithData(NSKeyedArchiver.archivedDataWithRootObject(menuTextView)) as UITextView
        menuCopy.addSubview(menuTextCopy)
        menuTextCopy.text = calendarEvent.descriptionProperty
        return menuCopy
    }
    
    @IBAction func onPan(sender: UIPanGestureRecognizer) {
        var screenWidth = UIScreen.mainScreen().bounds.width
        var translation = sender.translationInView(view)
        
        if (sender.state == UIGestureRecognizerState.Began) {
            nextIndex = translation.x < 0 ? lunchEvents?.nextIndex(currentLunchIndex) : lunchEvents?.previousIndex(currentLunchIndex)
            
            // If there's another calendar event
            if (nextIndex != nil) {
                
                // Copy this menu & fill in the data for the next menu item
                var nextCalendarEvent = lunchEvents?.getEvent(nextIndex!)
                menuCopy = createMenuViewCopy(nextCalendarEvent!)
                view.addSubview(menuCopy!)
            }
        }
        
        if (sender.state != UIGestureRecognizerState.Ended) {
            var menuOffset = CGFloat(0)
            
            // If there's another calendar event
            if (nextIndex != nil) {
                
                // Animate both views moving together to the left or right
                if (translation.x < 0) { // Swipe Left
                    menuCopy!.frame.origin.x = screenWidth + translation.x
                } else { // Swipe Right
                    menuCopy!.frame.origin.x = -screenWidth + translation.x
                }
                menuOffset = translation.x
                
            } else { // No next calendar event
                // Simulate resistive scroll
                menuOffset = translation.x / 10
            }
            
            menuView.frame.origin.x = menuOffset
            
            // Fade out title
            var titleColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1 - abs(menuOffset) / screenWidth)
            var textAttributes = NSDictionary(object: titleColor, forKey: NSForegroundColorAttributeName)
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        } else {
            // If there's another calendar event
            if (nextIndex != nil) {
                
                // Update title
                updateTitle(nextIndex!)
                
                // Animate paging to next event
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.menuCopy!.frame.origin.x = 0
                    self.menuView.frame.origin.x = ((translation.x < 0) ? -1 : 1) * screenWidth
                    }, completion: { (Bool) -> Void in
                        // Update the view for the new event
                        self.menuCopy!.removeFromSuperview()
                        self.menuCopy = nil
                        self.menuView.frame.origin.x = 0
                        
                        self.currentLunchIndex = self.nextIndex!
                        self.updateView()
                })
            } else { // No next calendar event
                // Animate back to the current event
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.menuView.frame.origin.x = 0
                })
            }
            
            // Fade in title
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                var textAttributes = NSDictionary(object: UIColor.blackColor(), forKey: NSForegroundColorAttributeName)
                self.navigationController?.navigationBar.titleTextAttributes = textAttributes
            })
        }
    }
}
