//
//  DocChatAlert.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-04-03.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation

struct DocChatAlert {
    
    static func displayAlertViewWithOTError(error: OTError) -> UIAlertController {
        
        let sessionAlertTitle   = NSLocalizedString("sessionErrorTitle", comment: "alert title")
        let actionTitle         = NSLocalizedString("sessionErrorAlertAction", comment: "alert action button")
        
        let alert = UIAlertController(title: sessionAlertTitle, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: { action in
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alert.addAction(okAction)
        return alert
    }
}