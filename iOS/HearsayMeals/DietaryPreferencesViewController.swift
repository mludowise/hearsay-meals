//
//  DietaryPreferencesViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/13/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

/*
0 = Omnivore
1 = Vegetarian
2 = Vegan
3 = Gluten
4 = Pescetarian
5 = Nuts
6 = Soy
7 = Eggs
8 = Dairy
9 = Shellfish
10 = Fish
11 = Pork
12 = Beef
13 = Lamb
14 = Poultry
*/
class DietaryPreferencesViewController: UITableViewController {
    
    @IBOutlet weak var omnivoreRow: UITableViewCell!
    @IBOutlet weak var pescetarianRow: UITableViewCell!
    @IBOutlet weak var vegetarianRow: UITableViewCell!
    @IBOutlet weak var veganRow: UITableViewCell!
    
    @IBOutlet weak var glutenRow: DietaryRestrictionTableCell!
    @IBOutlet weak var nutsRow: DietaryRestrictionTableCell!
    @IBOutlet weak var soyRow: DietaryRestrictionTableCell!
    
    @IBOutlet weak var eggsRow: DietaryRestrictionTableCell!
    @IBOutlet weak var dairyRow: DietaryRestrictionTableCell!
    
    @IBOutlet weak var shellFishRow: DietaryRestrictionTableCell!
    @IBOutlet weak var fishRow: DietaryRestrictionTableCell!
    
    @IBOutlet weak var porkRow: DietaryRestrictionTableCell!
    @IBOutlet weak var beefRow: DietaryRestrictionTableCell!
    @IBOutlet weak var lambRow: DietaryRestrictionTableCell!
    @IBOutlet weak var poultryRow: DietaryRestrictionTableCell!
    
    var allRestrictions = [DietaryRestrictionTableCell]()
    var nonVeggieRestrictions = [DietaryRestrictionTableCell]()
    var nonVeganRestrictions = [DietaryRestrictionTableCell]()
    var nonPescRestrictions = [DietaryRestrictionTableCell]()
    var meatRestrictions = [UITableViewCell]()
    
    var selectedMeatRestriction: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectCell(omnivoreRow)
        
        nonPescRestrictions.append(porkRow)
        nonPescRestrictions.append(beefRow)
        nonPescRestrictions.append(lambRow)
        nonPescRestrictions.append(poultryRow)
        
        nonVeggieRestrictions = nonPescRestrictions
        nonVeggieRestrictions.append(shellFishRow)
        nonVeggieRestrictions.append(fishRow)
        
        nonVeganRestrictions = nonVeggieRestrictions
        nonVeganRestrictions.append(eggsRow)
        nonVeganRestrictions.append(dairyRow)
        
        allRestrictions = nonVeganRestrictions
        allRestrictions.append(soyRow)
        allRestrictions.append(nutsRow)
        allRestrictions.append(glutenRow)
        
        meatRestrictions.append(omnivoreRow)
        meatRestrictions.append(pescetarianRow)
        meatRestrictions.append(vegetarianRow)
        meatRestrictions.append(veganRow)
        
        var preferences = PFUser.currentUser()[kUserPreferencesKey] as [Int]?
        if (preferences != nil) {
            for option in allRestrictions {
                if (find(preferences!, option.tag) != nil) {
                    option.switchView.on = true
                }
            }
            
            for meatRestriction in meatRestrictions {
                if (find(preferences!, meatRestriction.tag) != nil) {
                    selectCell(meatRestriction)
                    break
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath)
        if (indexPath.section == 0 && cell != selectedMeatRestriction) {
            selectCell(cell!)
            
            var preferencesToRemove = [Int]()
            for meatRestriction in meatRestrictions {
                if (meatRestriction != cell) {
                    preferencesToRemove.append(meatRestriction.tag)
                }
            }

            PFUser.currentUser().addUniqueObject(cell!.tag, forKey: kUserPreferencesKey)
            PFUser.currentUser().saveInBackgroundWithBlock({ (b: Bool, error: NSError!) -> Void in
                PFUser.currentUser().removeObjectsInArray(preferencesToRemove, forKey: kUserPreferencesKey)
                PFUser.currentUser().saveInBackground()
            })
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    private func selectCell(cell: UITableViewCell) {
        selectedMeatRestriction?.accessoryType = UITableViewCellAccessoryType.None
        selectedMeatRestriction = cell
        selectedMeatRestriction.accessoryType = UITableViewCellAccessoryType.Checkmark
    }
    
}

class DietaryRestrictionTableCell : UITableViewCell {
    var switchView = UISwitch()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        switchView.addTarget(self, action: "didSwitchChange:", forControlEvents: UIControlEvents.ValueChanged)
        self.accessoryView = switchView
    }
    
    func didSwitchChange(sender: UISwitch) {
        if (sender.on) {
            PFUser.currentUser().addUniqueObject(tag, forKey: kUserPreferencesKey)
        } else {
            PFUser.currentUser().removeObject(tag, forKey: kUserPreferencesKey)
        }
        PFUser.currentUser().saveInBackground()
    }
}