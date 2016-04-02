//
//  DocChatViewController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-26.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import UIKit

final class DocChatViewController: UIViewController {
    
    private let openTokController = OpenTokController()
    
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
        openTokController.connectToOTSession { session in
            
            guard let openTokSession = session else {
                
                // TODO: handle result/error
                return
            }
            
            // enable video display
            self.videoViewController.displayPublisherViewFromSession(openTokSession)
            
            // enable text messaging
            self.textViewController.enableTextChatInSession(openTokSession)
            self.textViewController.updateMessagesWithController(self.openTokController)
        }
    }
    
    private func displayVideoChatController() {
        
        self.navigationController?.pushViewController(videoViewController, animated: true)
    }

    
    // MARK: Actions
    
    func startTextChat() {
     
        self.navigationController?.pushViewController(textViewController, animated: true)
    }
}