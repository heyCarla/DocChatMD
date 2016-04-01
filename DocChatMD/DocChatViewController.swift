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
        
        displayVideoChatController()
        displayTextChatController()
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
//            self.textViewController.updateWithController(self.openTokController)
        }
    }
    
    private func displayVideoChatController() {
        
        self.view.addSubview(videoViewController.view)
    }
    
    private func displayTextChatController() {
        
        self.view.addSubview(textViewController.view)
    }
    
//    deinit{
//        print("DocChatViewController Deinit")
//    }
}