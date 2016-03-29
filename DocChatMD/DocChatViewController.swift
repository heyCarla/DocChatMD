//
//  DocChatViewController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-26.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import UIKit

final class DocChatViewController: UIViewController {
    
    private lazy var videoViewController: VideoChatViewController = {
        return VideoChatViewController()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayVideoChatController()
    }

    private func displayVideoChatController() {
        
        self.view.addSubview(videoViewController.view)
    }
    
//    deinit{
//        print("DocChatViewController Deinit")
//    }
}