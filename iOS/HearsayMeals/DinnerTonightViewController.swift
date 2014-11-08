//
//  DinnerTonightViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/8/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

private var userOrdered = false
private var userRequest : String?

class DinnerTonightViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var orderedStatusView: UIView!
    
    @IBOutlet weak var notOrderedView: UIView!
    @IBOutlet weak var timeLeftLabel: UILabel!
    
    @IBOutlet weak var orderedView: UIView!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var orderButtonActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cancelOrderButton: UIButton!
    @IBOutlet weak var cancelOrderActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var specialRequestEmptyView: UIView!
    @IBOutlet weak var specialRequestFilledView: UIView!
    @IBOutlet weak var specialRequestLabel: UILabel!
    
    @IBOutlet weak var peopleView: UIView!
    @IBOutlet weak var peopleTableLabel: UILabel!
    @IBOutlet weak var minimumPeopleMetLabel: UILabel!
    @IBOutlet weak var peopleTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (userOrdered) {
            notOrderedView.alpha = 0
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: orderedStatusView.frame.height + peopleView.frame.height)
        
        if (userRequest != nil) {
            specialRequestLabel.text = userRequest
            specialRequestEmptyView.hidden = true
        } else {
            specialRequestFilledView.hidden = true
        }
    }

    @IBAction func onOrderButton(sender: AnyObject) {
        orderButton.enabled = false
        orderButtonActivityIndicator.startAnimating()
        delay(2, { () -> () in
            userOrdered = true
            self.orderButtonActivityIndicator.stopAnimating()
            self.orderButton.enabled = true
            UIView.animateWithDuration(0.5) { () -> Void in
                self.notOrderedView.alpha = 0
            }
        })
        
    }
    
    @IBAction func onCancelButton(sender: AnyObject) {
        cancelOrderButton.hidden = true
        cancelOrderActivityIndicator.startAnimating()
        delay(0.5, { () -> () in
            self.cancelOrderActivityIndicator.stopAnimating()
            self.cancelOrderButton.hidden = false
            userOrdered = false
            
            UIView.animateWithDuration(0.5) { () -> Void in
                self.notOrderedView.alpha = 1
            }
        })
    }
    
    @IBAction func editSpecialRequest(sender: AnyObject) {
        
    }
    
    @IBAction func onCalendarButton(sender: AnyObject) {
        
    }
}
