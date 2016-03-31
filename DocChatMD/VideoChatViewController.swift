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
    
    private var frontCameraLeftConstraint: Constraint?
    private var audioTopConstraint: Constraint?
    private var audioLeftConstraint: Constraint?
    private var endVideoLeftConstraint: Constraint?
    private var endVideoBottomConstraint: Constraint?
    
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
        
        videoSettingsButton.backgroundColor = .grayColor()
        videoSettingsButton.addTarget(self, action: #selector(revealSettingsButtons), forControlEvents: .TouchUpInside)
        publisherView.addSubview(videoSettingsButton)

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
                
                //make.right.bottom.equalTo(subscriberView)
                make.left.centerY.equalTo(subscriberView).inset(UIEdgeInsetsMake(0, -30, 0, 0))
                
            } else {
                
                make.left.centerY.equalTo(subscriberView).inset(UIEdgeInsetsMake(0, -30, 0, 0))
            }
        }
        
        resetButtonConstraints()
    }

    private func resetButtonConstraints() {
        
        publisherAudioButton.snp_makeConstraints { make in
            
            make.left.right.width.height.equalTo(videoSettingsButton)
            self.audioLeftConstraint    = make.left.equalTo(videoSettingsButton).offset(0).constraint
            self.audioTopConstraint     = make.top.equalTo(videoSettingsButton).offset(0).constraint
        }
        
        frontCameraButton.snp_makeConstraints { make in

            make.top.bottom.width.equalTo(videoSettingsButton)
            self.frontCameraLeftConstraint = make.left.equalTo(videoSettingsButton).offset(0).constraint
        }
        
        endVideoButton.snp_makeConstraints { make in
            
            make.left.right.height.equalTo(videoSettingsButton)
            self.endVideoBottomConstraint   = make.bottom.equalTo(videoSettingsButton).offset(0).constraint
            self.endVideoLeftConstraint     = make.left.equalTo(videoSettingsButton).offset(0).constraint
        }
        
        buttonsHidden = true
    }
    
    private func animateButtonConstraints(areButtonsHidden: Bool) {
        
        if areButtonsHidden == true {
            
            let buttonOffset: CGFloat   = 10
            let leftOffset              = self.videoSettingsButton.frame.size.width + buttonOffset
            
            // update constraints
            self.frontCameraLeftConstraint!.updateOffset(-leftOffset)
            self.audioLeftConstraint!.updateOffset(-(leftOffset/2))
            self.audioTopConstraint!.updateOffset(-leftOffset)
//            self.endVideoLeftConstraint!.updateOffset(-leftOffset)
//            self.endVideoBottomConstraint!.updateOffset(-(leftOffset/2))
            
            publisherView.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(1.2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                
                self.publisherView.layoutIfNeeded()
                
                self.frontCameraButton.alpha    = 1
                self.publisherAudioButton.alpha = 1
                self.endVideoButton.alpha       = 1
                self.buttonsHidden              = false
                
            }, completion: nil)
        
        } else {
            
//            self.frontCameraLeftConstraint!.updateOffset(0)
//            self.audioLeftConstraint!.updateOffset(0)
//            self.audioTopConstraint!.updateOffset(0)

            resetButtonConstraints()
            publisherView.setNeedsUpdateConstraints()

            UIView.animateWithDuration(1.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                
                self.frontCameraButton.alpha     = 0
                self.publisherAudioButton.alpha  = 0
                self.endVideoButton.alpha        = 0

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
