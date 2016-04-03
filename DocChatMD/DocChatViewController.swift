//
//  DocChatViewController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-26.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import UIKit

final class DocChatViewController: UIViewController, VideoChatViewControllerDelegate {
    
    private let openTokController = OpenTokController()
//    private var textViewController: TextChatViewController?
    
    private lazy var videoViewController: VideoChatViewController = {
        return VideoChatViewController()
    }()
    private lazy var textViewController: TextChatViewController = {
        return TextChatViewController()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // config. the navigation bar
        title = "Doc Chat"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Chat", style: .Plain, target: self, action:#selector(startTextChat))

        // create video and text chat views
        displayVideoChatController()
        connectToOpenTokSession()
    }

    private func connectToOpenTokSession() {
        
        // run new instance of OpenTok session
//        openTokController.connectToOTSession { sessionResult in
        openTokController.connectToOTSessionFromController(self) { sessionResult in
            
            guard let openTokSession = sessionResult.value() else {
                
                // display error alert
                let alert = UIAlertController(title: "Video Chat Session Error", message: "Invalid session, please try again.", preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "Reload", style: UIAlertActionStyle.Default, handler: { action in
                    
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    self.restartSession()
                })
                
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
                
                return
            }
            
            // enable video display
            self.videoViewController.displayPublisherViewFromSession(openTokSession)
            
            // enable text messaging
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Chat", style: .Plain, target: self, action:#selector(self.startTextChat))
            self.textViewController.enableTextChatInSession(openTokSession)
            self.textViewController.updateMessagesWithController(self.openTokController)
        }
    }
    
    private func displayVideoChatController() {
        
        videoViewController.delegate    = self
        videoViewController.view.alpha  = 0
        self.view.addSubview(videoViewController.view)
        
        UIView.animateWithDuration(0.3, animations: {
            
            self.videoViewController.view.alpha = 1
            }, completion: nil)
    }

    
    // MARK: Actions
    
    internal func startTextChat() {
     
        self.navigationController?.pushViewController(textViewController, animated: true)
    }
    
    
    // MARK: VideoChatViewControllerDelegate Method(s)
    
    func restartSession() {
        
        self.navigationItem.rightBarButtonItem = nil
        textViewController.removePreviousChatMessages()
        
        displayVideoChatController()
        connectToOpenTokSession()
    }
}