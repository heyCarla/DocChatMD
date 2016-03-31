//
//  VideoSettingsControl.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-31.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class VideoSettingsControl: UIControl {
    
    var controlView: UIView?
    
    // settings UI
    let publisherAudioButton    = UIButton(frame: CGRectZero)
    let frontCameraButton       = UIButton(frame: CGRectZero)
    let endVideoButton          = UIButton(frame: CGRectZero)
    let videoSettingsButton     = UIButton(frame: CGRectZero)
    private var buttonsHidden   = true
    
    private var frontCameraLeftConstraint: Constraint?
    private var audioTopConstraint: Constraint?
    private var audioLeftConstraint: Constraint?
    private var endVideoLeftConstraint: Constraint?
    private var endVideoBottomConstraint: Constraint?
    
    func displayVideoButtonsInView(view: UIView?) {
        
        guard let newView = view else {
            
            return
        }
        
        controlView = newView
        //if controlView == view {
           
            publisherAudioButton.backgroundColor    = .yellowColor()
            publisherAudioButton.alpha              = 0
            publisherAudioButton.addTarget(self, action: #selector(togglePublisherMic), forControlEvents: .TouchUpInside)
            controlView!.addSubview(publisherAudioButton)
            
            frontCameraButton.backgroundColor   = .orangeColor()
            frontCameraButton.alpha             = 0
            frontCameraButton.addTarget(self, action: #selector(toggleCameraPosition), forControlEvents: .TouchUpInside)
            controlView!.addSubview(frontCameraButton)
            
            endVideoButton.backgroundColor  = .redColor()
            endVideoButton.alpha            = 0
            endVideoButton.addTarget(self, action: #selector(endVideoChat), forControlEvents: .TouchUpInside)
            controlView!.addSubview(endVideoButton)
            
            videoSettingsButton.backgroundColor = .grayColor()
            videoSettingsButton.addTarget(self, action: #selector(revealSettingsButtons), forControlEvents: .TouchUpInside)
            controlView!.addSubview(videoSettingsButton)
        //}
    }
    
    func resetButtonConstraints() {
        
        publisherAudioButton.snp_removeConstraints()
        frontCameraButton.snp_removeConstraints()
        endVideoButton.snp_removeConstraints()
        
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

    private func animateButtonConstraintsInView(areButtonsHidden: Bool, view: UIView) {
        
        if areButtonsHidden == true {
            
            let buttonOffset: CGFloat   = 10
            let leftOffset              = self.videoSettingsButton.frame.size.width + buttonOffset
            
            // update constraints
            self.frontCameraLeftConstraint!.updateOffset(-leftOffset)
            self.audioLeftConstraint!.updateOffset(-(leftOffset/2))
            self.audioTopConstraint!.updateOffset(-leftOffset)
            self.endVideoLeftConstraint!.updateOffset(-leftOffset)
            self.endVideoBottomConstraint!.updateOffset(-(leftOffset/2))
            
            //publisherView.setNeedsUpdateConstraints()
            view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(1.2, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                
                //self.publisherView.layoutIfNeeded()
                view.layoutIfNeeded()
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
            view.setNeedsUpdateConstraints()
            
            UIView.animateWithDuration(1.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
                
                self.frontCameraButton.alpha     = 0
                self.publisherAudioButton.alpha  = 0
                self.endVideoButton.alpha        = 0
                
                }, completion: nil)
        }
    }
    
    
    // MARK: Actions
    
    func revealSettingsButtons() {
        
        videoSettingsButton.removeTarget(self, action: #selector(revealSettingsButtons), forControlEvents: .TouchUpInside)
        videoSettingsButton.addTarget(self, action: #selector(hideSettingsButtons), forControlEvents: .TouchUpInside)
        animateButtonConstraintsInView(buttonsHidden, view: controlView!)
    }
    
    func hideSettingsButtons() {
        
        animateButtonConstraintsInView(buttonsHidden, view: controlView!)
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
}