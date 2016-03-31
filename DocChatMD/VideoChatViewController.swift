//
//  VideoChatViewController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-29.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation
import SnapKit

final class VideoChatViewController: UIViewController {
    
    private let openTokController   = OpenTokController()
    private let subscriberView      = UIView(frame: CGRectZero)
    private var publisherView       = UIView(frame: CGRectZero)
    private let settingsControl     = VideoSettingsControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createVideoViews()
    }
    
    
    // MARK: UI Elements
    
    private func createVideoViews() {
        
        publisherView.frame    = self.view.frame
        publisherView.hidden   = true
        self.view.addSubview(publisherView)
        
        subscriberView.backgroundColor      = .greenColor()
        subscriberView.layer.borderWidth    = 2
        subscriberView.layer.borderColor    = UIColor.whiteColor().CGColor
        subscriberView.hidden               = true
        publisherView.addSubview(subscriberView)
    }
    
    private func layoutViewElements() {
     
        subscriberView.snp_makeConstraints { (make) in
            
            make.width.height.equalTo(150)
            make.right.bottom.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 10, 10))
        }
        
        settingsControl.videoSettingsButton.snp_makeConstraints { (make) in
            
            make.width.height.equalTo(60)
            
            // if test subscriber view isn't already visible, add settings button in it's place
            // otherwise place it to the left of the subscriber view
            
            //subscriberView.hidden = false // TESTING POSITION IF SUBSCRIBER IS PRESENT *** /////
            ////////////////////////////////
            
            if subscriberView.hidden == true {
                
                make.centerX.centerY.equalTo(subscriberView).inset(UIEdgeInsetsMake(-10, 0, 0, 0))
                
            } else {
                
                make.left.centerY.equalTo(subscriberView).inset(UIEdgeInsetsMake(0, -30, 0, 0))
            }
        }
        
        settingsControl.resetButtonConstraints()
    }
    
    
    // MARK: Video Session Display
    
    func displayPublisherViewFromSession(session: OTSession?) {
        
        guard let currentSession = session else {
         
            print("invalid session")
            // TODO: handle result/error
            return
        }
        
        guard let publisher = openTokController.createOTPublisher() else {
            
            print("invalid publisher")
            // TODO: handle result/error
            return
        }
        
        openTokController.addPublisherToSession(currentSession, publisher: publisher)
        publisher.view.frame = publisherView.frame
        publisherView.hidden = false
        publisherView.addSubview(publisher.view)

        //createVideoButtons()
        settingsControl.displayVideoButtonsInView(publisherView)
        layoutViewElements()
    }
    
    func displaySubscriberViewWithSubscriber(subscriber: OTSubscriber?) {
        
        // TODO: un-hide subscriber
        
        guard let newSubscriber = subscriber else {
            
            // TODO: handle result/error
            return
        }
        
        subscriberView.hidden = false
        subscriberView.addSubview(newSubscriber.view)
    }

}
