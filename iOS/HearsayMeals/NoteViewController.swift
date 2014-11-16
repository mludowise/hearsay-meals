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
    
    private var initialText : String?
    private var onDone : ((String) -> Void)?
    private var titleBarText : String?
    private var allowEmpty = false
    
    internal func initialize(text: String?, title: String?, allowEmpty: Bool, onDone: ((String) -> Void)?) {
        initialText = text
        titleBarText = title
        self.onDone = onDone
        self.allowEmpty = allowEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textArea.text = initialText?
        textArea.delegate = self
        
        textArea.becomeFirstResponder()
        titleBar.title = titleBarText?
        doneButton.enabled = allowEmpty || initialText == nil || initialText == ""
    }
    
    func textViewDidChange(textView: UITextView) {
        if (!allowEmpty) {
            doneButton.enabled = textArea.text != ""
        }
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
