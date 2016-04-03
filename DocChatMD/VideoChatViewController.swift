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
    
    case remoteViewNotFound
    case localViewNotFound
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

typealias RemoteViewDisplayCompletion   = (result: Result<OTSession>) -> Void
typealias PublisherCreationCompletion   = (result: Result<OTPublisher>) -> Void
typealias LocalViewDisplayCompletion    = (result: Result<OTSession>) -> Void

final class VideoChatViewController: UIViewController, SettingsControlDelegate, RestartSessionViewDelegate {
    
    weak var delegate: VideoChatViewControllerDelegate?
    private let openTokController   = OpenTokController()
    private var remoteView          = UIView(frame: CGRectZero)
    private let localView           = UIView(frame: CGRectZero)
    private var settingsControl     = SettingsControl()
    private var videoSession: OTSession?
    private var publisher: OTPublisher?
    private var restartSessionView: RestartSessionView?
    private var remoteViewDisplayCompletion: RemoteViewDisplayCompletion?
    private var publisherCreationCompletion: PublisherCreationCompletion?
    private var localViewDisplayCompletion: LocalViewDisplayCompletion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsControl.delegate = self
        createVideoViews()
    }

    
    // MARK: UI Elements
    
    private func createVideoViews() {
        
        remoteView.frame             = self.view.frame
        remoteView.backgroundColor   = .blackColor()
        remoteView.hidden            = true
        self.view.addSubview(remoteView)
        
        localView.backgroundColor      = .blackColor()
        localView.layer.borderWidth    = 2
        localView.layer.borderColor    = UIColor.whiteColor().CGColor
        localView.hidden               = true
        self.view.addSubview(localView)
    }
    
    private func layoutViewElements() {
     
        localView.snp_makeConstraints { (make) in
            
            make.width.height.equalTo(150)
            make.right.bottom.equalTo(self.view).inset(UIEdgeInsetsMake(0, 0, 10, 10))
        }
        
        publisher?.view.snp_makeConstraints { (make) in
            
            make.width.height.equalTo(localView)
            make.edges.equalTo(localView)
        }
        
        settingsControl.mainButton.snp_makeConstraints { (make) in
            
            make.width.height.equalTo(60)
            make.left.centerY.equalTo(localView).inset(UIEdgeInsetsMake(0, -30, 0, 0))
        }
        
        settingsControl.resetButtonConstraints()
    }
    
    
    // MARK: Video Session Display
    
    func displayRemoteViewFromSession(session: OTSession?) {
        
        guard let currentSession = session else {
         
            remoteViewDisplayCompletion?(result: Result.failure(error: VideoViewError.remoteViewNotFound))
            remoteViewDisplayCompletion = nil
            return
        }
        
        videoSession        = currentSession
        let publisherResult = openTokController.createOTPublisher()
            
        guard let publisher = publisherResult.value() else {
            
            publisherCreationCompletion?(result: Result.failure(error: OTSessionError.PublisherNotCreated))
            remoteViewDisplayCompletion = nil
            return
        }
        
        self.publisher = publisher
        
        if let error:OTError = openTokController.addPublisherToSession(currentSession, publisher: publisher) {
            
            let alert = DocChatAlert.displayAlertViewWithOTError(error)
            presentViewController(alert, animated: true, completion: nil)
        }

        localView.hidden            = false
        localView.addSubview(publisher.view)
        
        settingsControl.displaySettingsButtonsInView(self.view)
        layoutViewElements()
    }
 
    func displayLocalViewWithSubscriber(subscriber: OTSubscriber?) {
        
        guard let newSubscriber = subscriber else {
            
            localViewDisplayCompletion?(result: Result.failure(error: VideoViewError.localViewNotFound))
            localViewDisplayCompletion = nil
            return
        }
        
        remoteView.hidden = false
        remoteView.addSubview(newSubscriber.view)
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
    }

    func didSelectButtonThree() {
        
        // end the OpenTok session
        remoteView.hidden       = true
        localView.hidden        = true
        
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

        settingsControl.hideSettingsButtons()
        settingsControl.mainButton.hidden = true

        UIView.animateWithDuration(0.3, animations: { 
            self.restartSessionView!.alpha = 0
            
        }) { finished in
            self.restartSessionView!.removeFromSuperview()
        }
        
        delegate?.restartSession()
    }
}
