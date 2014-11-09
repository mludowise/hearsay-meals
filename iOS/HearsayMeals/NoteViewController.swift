//
//  noteViewController.swift
//  HearsayMeals
//
//  Created by Mel Ludowise on 11/8/14.
//  Copyright (c) 2014 Mel Ludowise. All rights reserved.
//

import UIKit

internal var kNoteViewControllerID = "noteViewController"

class NoteViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var initialText : String?
    var onDone : ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (initialText != nil) {
            textArea.text = initialText
        }
        
        textArea.delegate = self
        textArea.becomeFirstResponder()
    }
    
    func textViewDidChange(textView: UITextView) {
        doneButton.enabled = textArea.text != ""
    }
    
    @IBAction func onDone(sender: AnyObject) {
        if (onDone != nil) {
            onDone!(textArea.text)
        }
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
