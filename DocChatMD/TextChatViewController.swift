//
//  TextChatViewController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-29.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation
import UIKit

final class TextChatViewController: UIViewController, UITextFieldDelegate {
    
    let textField   = UITextField()
    var textView    = UITextView()
    var currentSession: OTSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayTextUIElements()
    }

    func enableChatTextFieldForSession(session: OTSession?) {
        
        // TODO: adjust sizes w/ autolayout later x_x
        
        guard let newSession = session else {
            
            print("something went wrong")
            // TODO: handle session/error
            return
        }
        
        currentSession = newSession
        
        textField.becomeFirstResponder()
        textField.userInteractionEnabled = true
    }
    
    func updateWithController(controller: OpenTokController) {
        
        controller.messageReceivedClosure = { text, isLocal in
            
            self.logSignalStringInTextView(text!, textView: self.textView, isLocalClient: isLocal)
        }
    }
    
    private func displayTextUIElements() {
        
        textField.delegate                  = self
        textField.frame                     = CGRect(x: 0, y: 40, width: self.view.frame.width, height: 40)
        textField.backgroundColor           = .yellowColor()
        textField.userInteractionEnabled    = false
        textField.returnKeyType             = .Done
        self.view.addSubview(textField)
        
        textView.frame                  = CGRect(x: 0, y: textField.frame.origin.y+40, width: self.view.frame.width, height: 300)
        textView.userInteractionEnabled = false
        textView.backgroundColor        = .redColor()
        self.view.addSubview(textView)
    }

    private func logSignalStringInTextView(string: String, textView: UITextView, isLocalClient: Bool) {
        
        let previousStringLength = textView.text.characters.count - 1
        textView.insertText("\(string)\n")
        
        if isLocalClient {
            
            // change the colour of messages submitted by the local user
            let formatDict: [String:UIColor]    = [NSForegroundColorAttributeName: .blueColor()]
            let textRange                       = NSMakeRange(previousStringLength + 1, string.characters.count)
            textView.textStorage.setAttributes(formatDict, range: textRange)
        }
        
        textView.setContentOffset(textView.contentOffset, animated: false)
        textView.scrollRangeToVisible(NSMakeRange(textView.text.characters.count, 0))
    }
    
    
    // MARK: UITextFieldDelegate Method(s)
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        
        textField.text = ""
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        guard let text = textField.text else {
            
            // TODO: handle error/result
            return false
        }
        
        OpenTokTextChatController().sendChatMessageInSession(currentSession!, message: text)
        
        // reset the textfield for the next message
        textField.text = ""
        textField.resignFirstResponder()
        
        return true
    }
}