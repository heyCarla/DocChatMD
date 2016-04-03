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

private extension AVCaptureDevicePosition {
    
    func reverseValue() -> AVCaptureDevicePosition {
        
        switch self {
        case .Front:
            return .Back
        case .Back:
            return .Front
        default:
            return .Unspecified
        }
    }
}

protocol VideoChatViewControllerDelegate: class {
    
    func restartSession()
}

typealias PublisherViewDisplayCompletion    = (result: Result<OTSession>) -> Void
typealias PublisherCreationCompletion       = (result: Result<OTPublisher>) -> Void
typealias SubscriberViewDisplayCompletion   = (result: Result<OTSession>) -> Void

final class VideoChatViewController: UIViewController, SettingsControlDelegate, RestartSessionViewDelegate {
    
    private var publisherViewDisplayCompletion: PublisherViewDisplayCompletion?
    private var publisherCreationCompletion: PublisherCreationCompletion?
    private var subscriberViewDisplayCompletion: SubscriberViewDisplayCompletion?
    
    weak var delegate: VideoChatViewControllerDelegate?
    private let openTokController   = OpenTokController()
    private var videoSession: OTSession?
    private var publisher: OTPublisher?
    private var publisherView       = UIView(frame: CGRectZero)
    private let subscriberView      = UIView(frame: CGRectZero)
    private var settingsControl     = SettingsControl()
    private var restartSessionView: RestartSessionView?
    
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
        
        videoSession        = currentSession
        let publisherResult = openTokController.createOTPublisher()
            
        guard let publisher = publisherResult.value() else {
            
            publisherCreationCompletion?(result: Result.failure(error: OTSessionError.PublisherNotCreated))
            publisherViewDisplayCompletion = nil
            return
        }
        
        self.publisher = publisher
        
        if let error:OTError = openTokController.addPublisherToSession(currentSession, publisher: publisher) {
            
            let alert = DocChatAlert.displayAlertViewWithOTError(error)
            presentViewController(alert, animated: true, completion: nil)
        }

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
    
    func didSelectButtonOne() {
        
        // mute/unmute publisher audio
        publisher!.publishAudio = !publisher!.publishAudio
        
        // update button image
        let imageName: String
        
        if publisher!.publishAudio {
            // display mute image
            imageName = "mute"
        } else {
            // display mic image
            imageName = "unmute"
        }
        
        settingsControl.buttonOne.setImage(UIImage(named: "\(imageName).png"), forState: .Normal)
        settingsControl.buttonOne.setImage(UIImage(named: "\(imageName)Highlighted.png"), forState: .Highlighted)
    }
    
    func didSelectButtonTwo() {
        
        publisher!.cameraPosition = publisher!.cameraPosition.reverseValue()
        
//        // toggle between front/back cameras
//        if publisher!.cameraPosition == .Front {
//            publisher!.cameraPosition = .Back
//        } else {
//            publisher!.cameraPosition = .Front
//        }
    }

    func didSelectButtonThree() {
        
        // end the OpenTok session
        publisherView.hidden    = true
        subscriberView.hidden   = true
        openTokController.endCurrentOTSession(videoSession)
        
        // add a view to restart the session
        restartSessionView              = RestartSessionView(frame: self.view.frame)
        restartSessionView!.delegate    = self
        restartSessionView!.alpha       = 0
        self.view.addSubview(restartSessionView!)
        
        UIView.animateWithDuration(0.3, animations: { 
            
            self.restartSessionView!.alpha = 1
        }, completion: nil)
    }
    
    
    // MARK: RestartSessionViewDelegate Method(s)
    
    func didSelectRestartSession() {

        UIView.animateWithDuration(0.3, animations: { 
            self.restartSessionView!.alpha = 0
            
        }) { finished in
            self.restartSessionView!.removeFromSuperview()
        }
        
        delegate?.restartSession()
    }
}
