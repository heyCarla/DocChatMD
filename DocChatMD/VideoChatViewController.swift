//
//  VideoChatViewController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-29.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation
import SnapKit

enum VideoViewError: ErrorType {
    
    case PublisherViewNotFound
    case SubscriberViewNotFound
}

typealias PublisherViewDisplayCompletion    = (result: Result<OTSession>) -> Void
typealias PublisherCreationCompletion       = (result: Result<OTPublisher>) -> Void
typealias SubscriberViewDisplayCompletion   = (result: Result<OTSession>) -> Void

final class VideoChatViewController: UIViewController, SettingsControlDelegate {
    
    private var publisherViewDisplayCompletion: PublisherViewDisplayCompletion?
    private var publisherCreationCompletion: PublisherCreationCompletion?
    private var subscriberViewDisplayCompletion: SubscriberViewDisplayCompletion?
    
    private let openTokController   = OpenTokController()
    private let subscriberView      = UIView(frame: CGRectZero)
    private var publisherView       = UIView(frame: CGRectZero)
    private var publisher: OTPublisher?
    private var settingsControl     = SettingsControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsControl.delegate = self
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
         
            publisherViewDisplayCompletion?(result: Result.failure(error: VideoViewError.PublisherViewNotFound))
            publisherViewDisplayCompletion = nil
            return
        }
        
        let publisherResult = openTokController.createOTPublisher()
            
        guard let publisher = publisherResult.value() else {
            
            publisherCreationCompletion?(result: Result.failure(error: OTSessionError.PublisherNotCreated))
            publisherViewDisplayCompletion = nil
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
            
            subscriberViewDisplayCompletion?(result: Result.failure(error: VideoViewError.SubscriberViewNotFound))
            subscriberViewDisplayCompletion = nil
            return
        }
        
        subscriberView.hidden = false
        subscriberView.addSubview(newSubscriber.view)
    }

    
    // MARK: SettingsControlDelegate Methods
    
    func buttonOneAction() {
        
        // mute/unmute publisher audio
        publisher!.publishAudio = !publisher!.publishAudio
    }
    
    func buttonTwoAction() {
        
        // toggle between front/back cameras
        if publisher!.cameraPosition == .Front {
            publisher!.cameraPosition = .Back
        } else {
            publisher!.cameraPosition = .Front
        }
    }

    func buttonThreeAction() {
        
        // end the openTok session
        publisherView.removeFromSuperview()
        subscriberView.removeFromSuperview()
        
        openTokController.endCurrentOTSession()
    }
}
