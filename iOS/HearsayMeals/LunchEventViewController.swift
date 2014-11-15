//
//  LunchEventViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 10/13/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

let kLunchEventViewController = "lunchEventViewController"
private let kDayFormat = "EEE"

class LunchEventViewController: UIViewController {
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuTextView: UITextView!
    
    // To format date in title
    private var dateFormatter = NSDateFormatter()
    
    // Needed for swipe animation
    private var menuCopy: UIView?
    private var nextIndex: Int?

    // These should be set when the view is instantiated
    private var lunchEvents : [GTLCalendarEvent] = []
    private var currentLunchIndex = 0
    
    internal func initializeView(lunchEvents: [GTLCalendarEvent], currentLunchIndex: Int) {
        self.lunchEvents = lunchEvents
        self.currentLunchIndex = currentLunchIndex
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    private func updateView() {
        var calendarEvent = lunchEvents[currentLunchIndex]
        
        menuTextView.text = calendarEvent.descriptionProperty
        
        var start = calendarEvent.start.dateTime.date
        self.title = NSDateFormatter.localizedStringFromDate(start, dateStyle: NSDateFormatterStyle.FullStyle, timeStyle: NSDateFormatterStyle.NoStyle)
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
            nextIndex = getNextIndex(translation.x < 0)
            
            // If there's another calendar event
            if (nextIndex != nil) {
                
                // Copy this menu & fill in the data for the next menu item
                var nextCalendarEvent = lunchEvents[nextIndex!]
                menuCopy = createMenuViewCopy(nextCalendarEvent)
                view.addSubview(menuCopy!)
            }
        }
        
        
        
        if (sender.state != UIGestureRecognizerState.Ended) {
            
            // If there's another calendar event
            if (nextIndex != nil) {
                
                // Animate both views moving together to the left or right
                if (translation.x < 0) { // Swipe Left
                    menuCopy!.frame.origin.x = screenWidth + translation.x
                } else { // Swipe Right
                    menuCopy!.frame.origin.x = -screenWidth + translation.x
                }
                menuView.frame.origin.x = translation.x
                
            } else { // No next calendar event
                // Simulate resistive scroll
                menuView.frame.origin.x = translation.x / 10
            }
        } else {
            // If there's another calendar event
            if (nextIndex != nil) {
                
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
        }
    }
    
    private func getNextIndex(isSwipeLeft: Bool) -> Int? {
        var nextIndex = currentLunchIndex
        if (isSwipeLeft) {
            nextIndex++
        } else {
            nextIndex--
        }
        
        // If there is no other lunch menu to swipe through...
        if (nextIndex < 0 || nextIndex >= lunchEvents.count) {
            return nil
        }
        
        return nextIndex
    }
}
