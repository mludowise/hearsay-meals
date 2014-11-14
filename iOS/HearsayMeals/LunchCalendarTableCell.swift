//
//  LunchCalendarTableCell.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/13/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

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
