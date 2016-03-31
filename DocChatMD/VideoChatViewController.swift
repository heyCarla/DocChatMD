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
    
    // video views
    private let openTokController   = OpenTokController()
    private let subscriberView      = UIView(frame: CGRectZero) // TODO: replace with actual subscriber view once testing complete ***
    private var publisherView       = UIView(frame: CGRectZero)
   
    // settings UI
    private let publisherAudioButton    = UIButton(frame: CGRectZero)
    private let frontCameraButton       = UIButton(frame: CGRectZero)
    private let endVideoButton          = UIButton(frame: CGRectZero)
    private let videoSettingsButton     = UIButton(frame: CGRectZero)
    private var buttonsHidden           = true
    
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
    
    private func createVideoButtons() {
        
        videoSettingsButton.backgroundColor = .grayColor()
        videoSettingsButton.addTarget(self, action: #selector(revealSettingsButtons), forControlEvents: .TouchUpInside)
        publisherView.addSubview(videoSettingsButton)

        publisherAudioButton.backgroundColor    = .yellowColor()
        publisherAudioButton.alpha              = 0
        publisherAudioButton.addTarget(self, action: #selector(togglePublisherMic), forControlEvents: .TouchUpInside)
        publisherView.addSubview(publisherAudioButton)

        frontCameraButton.backgroundColor   = .orangeColor()
        frontCameraButton.alpha             = 0
        frontCameraButton.addTarget(self, action: #selector(toggleCameraPosition), forControlEvents: .TouchUpInside)
        publisherView.addSubview(frontCameraButton)

        endVideoButton.backgroundColor  = .redColor()
        endVideoButton.alpha            = 0
        endVideoButton.addTarget(self, action: #selector(endVideoChat), forControlEvents: .TouchUpInside)
        publisherView.addSubview(endVideoButton)
    }
    
    private func layoutViewElements() {
     
        subscriberView.snp_makeConstraints { (make) in
            
            make.width.height.equalTo(150)
            make.right.bottom.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 10, 10))
        }
        
        videoSettingsButton.snp_makeConstraints { (make) in
            
            make.width.height.equalTo(60)
            
            // if test subscriber view isn't already visible, add settings button in it's place
            // otherwise place it to the left of the subscriber view
            
            //subscriberView.hidden = false // TESTING POSITION IF SUBSCRIBER IS PRESENT *** /////
            ////////////////////////////////
            
            if subscriberView.hidden == true {
                
                make.right.bottom.equalTo(subscriberView)
                
            } else {
                
                make.left.centerY.equalTo(subscriberView).inset(UIEdgeInsetsMake(0, -30, 0, 0))
            }
        }
        
        resetButtonConstraints()
    }

    private func resetButtonConstraints() {
        
        publisherAudioButton.snp_makeConstraints { (make) in
            
            make.size.equalTo(videoSettingsButton)
            make.edges.equalTo(videoSettingsButton)
        }
        
        frontCameraButton.snp_makeConstraints { (make) in
            
            make.size.equalTo(videoSettingsButton)
            make.edges.equalTo(videoSettingsButton)
        }
        
        endVideoButton.snp_makeConstraints { (make) in
            
            make.size.equalTo(videoSettingsButton)
            make.edges.equalTo(videoSettingsButton)
        }
        
        buttonsHidden = true
    }
    
    private func animateButtonConstraints(areButtonsHidden: Bool) {
        
        if areButtonsHidden == true {
            
            UIView.animateWithDuration(1.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                
                let buttonOffset: CGFloat   = 10
                let leftOffset              = self.videoSettingsButton.frame.size.width + buttonOffset
                
                self.frontCameraButton.alpha     = 1
                self.publisherAudioButton.alpha  = 1
                self.endVideoButton.alpha        = 1

                self.frontCameraButton.snp_updateConstraints { (make) in
                    make.left.equalTo(self.videoSettingsButton).inset(UIEdgeInsetsMake(0, -leftOffset, 0, 0))
                }
                
                self.publisherAudioButton.snp_updateConstraints(closure: { (make) in
                    make.left.top.equalTo(self.videoSettingsButton).inset(UIEdgeInsetsMake(-leftOffset, -(leftOffset/2), 0, 0))
                })
                
                // TODO: fix oddly positioned end video button ***
                
                self.endVideoButton.snp_updateConstraints(closure: { (make) in
                    make.left.equalTo(self.videoSettingsButton).inset(UIEdgeInsetsMake(0, -(leftOffset/2), 0, 0))
                    make.bottom.greaterThanOrEqualTo(self.videoSettingsButton).inset(UIEdgeInsetsMake(0, 0, leftOffset, 0))
                })
                
                self.buttonsHidden = false
                
            }, completion: nil)
        
        } else {
            
            UIView.animateWithDuration(1.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                
                self.frontCameraButton.alpha     = 0
                self.publisherAudioButton.alpha  = 0
                self.endVideoButton.alpha        = 0
                
                // reset the settings button
                self.resetButtonConstraints()
                
            }, completion: nil)
        }
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

        createVideoButtons()
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
    
    
    // MARK: Actions
    
    func revealSettingsButtons() {
        
        videoSettingsButton.removeTarget(self, action: #selector(revealSettingsButtons), forControlEvents: .TouchUpInside)
        videoSettingsButton.addTarget(self, action: #selector(hideSettingsButtons), forControlEvents: .TouchUpInside)
        animateButtonConstraints(buttonsHidden)
    }
    
    func hideSettingsButtons() {
        
        animateButtonConstraints(buttonsHidden)
        videoSettingsButton.removeTarget(self, action: #selector(hideSettingsButtons), forControlEvents: .TouchUpInside)
        videoSettingsButton.addTarget(self, action: #selector(revealSettingsButtons), forControlEvents: .TouchUpInside)
    }
    
    func togglePublisherMic() {
        
        print("toggle mic")
//        publisher.publishAudio = !publisher.publishAudio
        
        // TODO: add button effects on controlstate change..
    }
    
    func toggleCameraPosition() {
        
        print("toggle front/back camera")
//        if publisher!.cameraPosition == .Front {
//            publisher!.cameraPosition = .Back
//        } else {
//            publisher!.cameraPosition = .Front
//        }
    }
    
    func endVideoChat() {
        
        print("end video session")
        // TODO: end openTok session
    }

//    deinit{
//        print("VideoChatVC Deinit")
//    }
}
