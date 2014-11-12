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

    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var textArea: UITextView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var initialText : String?
    var onDone : ((String) -> Void)?
    var titleBarText : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textArea.text = initialText?
        textArea.delegate = self
        textArea.becomeFirstResponder()
        titleBar.title = titleBarText?
    }
    
    func textViewDidChange(textView: UITextView) {
        doneButton.enabled = textArea.text != ""
    }
    
    @IBAction func onDone(sender: AnyObject) {
        onDone?(textArea.text)
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
