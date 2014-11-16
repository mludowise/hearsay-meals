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
    
    @IBOutlet weak var glutenRow: SwitchTableCell!
    @IBOutlet weak var nutsRow: SwitchTableCell!
    @IBOutlet weak var soyRow: SwitchTableCell!
    
    @IBOutlet weak var eggsRow: SwitchTableCell!
    @IBOutlet weak var dairyRow: SwitchTableCell!
    
    @IBOutlet weak var shellFishRow: SwitchTableCell!
    @IBOutlet weak var fishRow: SwitchTableCell!
    
    @IBOutlet weak var porkRow: SwitchTableCell!
    @IBOutlet weak var beefRow: SwitchTableCell!
    @IBOutlet weak var lambRow: SwitchTableCell!
    @IBOutlet weak var poultryRow: SwitchTableCell!
    
    @IBOutlet weak var additionalRestrictionsRow: UITableViewCell!
    
    var allRestrictions = [SwitchTableCell]()
    var nonVeggieRestrictions = [SwitchTableCell]()
    var nonVeganRestrictions = [SwitchTableCell]()
    var nonPescRestrictions = [SwitchTableCell]()
    var meatRestrictions = [UITableViewCell]()
    
    var selectedMeatRestriction: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Default to omnivore
        selectCell(omnivoreRow)
        
        nonPescRestrictions.append(porkRow)
        nonPescRestrictions.append(beefRow)
        nonPescRestrictions.append(lambRow)
        nonPescRestrictions.append(poultryRow)
        
        nonVeggieRestrictions += nonPescRestrictions
        nonVeggieRestrictions.append(shellFishRow)
        nonVeggieRestrictions.append(fishRow)
        
        nonVeganRestrictions += nonVeggieRestrictions
        nonVeganRestrictions.append(eggsRow)
        nonVeganRestrictions.append(dairyRow)
        
        allRestrictions += nonVeganRestrictions
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
        var preferenceNote = PFUser.currentUser()[kUserPreferenceNote] as? String
        setPreferenceNote(preferenceNote)
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
        } else if (cell == additionalRestrictionsRow) {
            var noteViewController = storyboard?.instantiateViewControllerWithIdentifier(kNoteViewControllerID) as NoteViewController
            noteViewController.initialize(PFUser.currentUser()[kUserPreferenceNote] as? String, title: "Additional Restrictions", allowEmpty: true, onDone: { (text: String) -> Void in
                PFUser.currentUser()[kUserPreferenceNote] = text
                PFUser.currentUser().saveInBackground()
                self.setPreferenceNote(text)
            })
            presentViewController(noteViewController, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    private func selectCell(cell: UITableViewCell) {
        selectedMeatRestriction?.accessoryType = UITableViewCellAccessoryType.None
        selectedMeatRestriction = cell
        selectedMeatRestriction.accessoryType = UITableViewCellAccessoryType.Checkmark
//        disableRestrictionsFromMeat(cell)
    }
    
    private func disableRestrictionsFromMeat(meatRestriction: UITableViewCell) {
        if (meatRestriction == omnivoreRow) {
            setEnableCells(nonVeganRestrictions, enabled: true)
        } else if (meatRestriction == pescetarianRow) {
            setEnableCells(nonPescRestrictions, enabled: false)
        } else if (meatRestriction == vegetarianRow) {
            setEnableCells(nonVeggieRestrictions, enabled: false)
        } else if (meatRestriction == veganRow) {
            setEnableCells(nonVeganRestrictions, enabled: false)
        }
    }
    
    private func setEnableCells(cells: [SwitchTableCell], enabled: Bool) {
        for cell in cells {
            if (enabled) {
                cell.hidden = false
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    cell.alpha = 1
                })
            } else {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    cell.alpha = 0
                    }, completion: { (Bool) -> Void in
                        cell.hidden = true
                })
            }
        }
    }
    
    private func setPreferenceNote(note: String?) {
        if (note == nil || note == "") {
            additionalRestrictionsRow.detailTextLabel?.text = "None"
//            additionalRestrictionsRow.textLabel.text = "None"
//            additionalRestrictionsRow.textLabel.textColor = UIColor.lightGrayColor()
        } else {
            additionalRestrictionsRow.detailTextLabel?.text = note
//            additionalRestrictionsRow.textLabel.text = note
//            additionalRestrictionsRow.textLabel.textColor = UIColor.blackColor()
        }
    }
}

class SwitchTableCell : UITableViewCell {
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