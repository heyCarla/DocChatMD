//
//  DocChatViewController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-26.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import UIKit
import SnapKit

final class DocChatViewController: UIViewController, VideoChatViewControllerDelegate {
    
    private let activityIndicator = UIActivityIndicatorView(frame: CGRectZero)
    private let openTokController = OpenTokController()
    private lazy var videoViewController: VideoChatViewController = {
        return VideoChatViewController()
    }()
    private lazy var textViewController: TextChatViewController = {
        return TextChatViewController()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createViewElements()
        layoutViewElements()
    }

    private func createViewElements() {
        
        // config. the navigation bar
        title = NSLocalizedString("navbarTitle", comment: "navbar title label")
        navigationController?.navigationBar.translucent = false

        // create video and text chat views
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        displayVideoChatController()
        connectToOpenTokSession()
    }
    
    private func layoutViewElements() {
        
        activityIndicator.snp_makeConstraints { (make) in
            
            make.width.height.equalTo(100)
            make.centerX.centerY.equalTo(self.view)
        }
    }

    private func connectToOpenTokSession() {
        
        // run new instance of OpenTok session
        openTokController.connectToOTSession() { sessionResult in
            
            guard let openTokSession = sessionResult.value() else {
                
                self.activityIndicator.stopAnimating()
                
                // display error alert
                let alert = UIAlertController(title: NSLocalizedString("sessionErrorTitle", comment: "invalid session"), message: NSLocalizedString("sessionErrorInvalid", comment: "invalid session"), preferredStyle: UIAlertControllerStyle.Alert)
                
                let okAction = UIAlertAction(title: NSLocalizedString("sessionErrorActionReload", comment: "reload"), style: UIAlertActionStyle.Default, handler: { action in
                    
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    self.restartSession()
                })
                
                alert.addAction(okAction)
                self.presentViewController(alert, animated: true, completion: nil)
                
                return
            }
            
            self.activityIndicator.stopAnimating()
            
            // enable video display
            self.videoViewController.displayPublisherViewFromSession(openTokSession)
            
            // enable text messaging
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("navbarChat", comment: "nav chat button label"), style: .Plain, target: self, action:#selector(self.startTextChat))
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
        
        textViewController.removePreviousChatMessages()
        
        createViewElements()
        layoutViewElements()
    }
}