//
//  VideoChatViewController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-29.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation
import SnapKit

final class VideoChatViewController: UIViewController, SettingsControlDelegate {
    
    private let openTokController   = OpenTokController()
    private let subscriberView      = UIView(frame: CGRectZero)
    private var publisherView       = UIView(frame: CGRectZero)
    private var publisher: OTPublisher?
    private var settingsControl     = SettingsControl()
    private var settingsControlDelegate: SettingsControlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsControlDelegate = self
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
        
        settingsControl.mainButton.snp_makeConstraints { (make) in
            
            make.width.height.equalTo(60)
            
            // if test subscriber view isn't already visible, add settings button in it's place
            // otherwise place it to the left of the subscriber view
            
            //subscriberView.hidden = false // TESTING POSITION IF SUBSCRIBER IS PRESENT *** /////
            ////////////////////////////////
            
            if subscriberView.hidden == true {
                
                make.right.bottom.equalTo(subscriberView).inset(UIEdgeInsetsMake(0, 0, -5, -5))
                
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
        
        let publisherResult = openTokController.createOTPublisher()
            
        guard let publisher = publisherResult.value() else {
            
            print("publisher error: \(publisherResult.error())")
            return
        }
        
        self.publisher = publisher
        
        openTokController.addPublisherToSession(currentSession, publisher: publisher)
        publisher.view.frame = publisherView.frame
        publisherView.hidden = false
        publisherView.addSubview(publisher.view)

        settingsControl.displaySettingsButtonsInView(publisherView)
        layoutViewElements()
    }

    func displaySubscriberViewWithSubscriber(subscriber: OTSubscriber?) {
        
        guard let newSubscriber = subscriber else {
            
            // TODO: handle result/error
            return
        }
        
        subscriberView.hidden = false
        subscriberView.addSubview(newSubscriber.view)
    }

    
    // MARK: SettingsControlDelegate Methods
    
    func buttonOneAction() {
        
        publisher!.publishAudio = !publisher!.publishAudio
    }
    
    func buttonTwoAction() {
        
        if publisher!.cameraPosition == .Front {
            publisher!.cameraPosition = .Back
        } else {
            publisher!.cameraPosition = .Front
        }

    }

    func buttonThreeAction() {
        
        // TODO: end openTok session

    }
}
