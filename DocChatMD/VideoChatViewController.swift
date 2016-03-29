//
//  VideoChatViewController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-29.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation

final class VideoChatViewController: UIViewController {
    
    // Video View vars --> // TODO: properly layout video frame ***
    let videoWidth  = 300
    let videoHeight = 400
    //////////////////////////
    
    private let openTokController = OpenTokController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .blueColor()
        
        // run new instance of OpenTok session
        openTokController.connectToOTSession { session in
            
            guard let openTokSession = session else {
                
                // TODO: handle result/error
                return
            }
            
            self.displayPublisherViewFromSession(openTokSession)
        }
    }
    
    func displayPublisherViewFromSession(session: OTSession) {
        
        guard let publisher = openTokController.createOTPublisher() else {
            
            // TODO: handle result/error
            return
        }
        
        openTokController.addPublisherToSession(session, publisher: publisher)
        self.view.addSubview(publisher.view)
        
        // TODO: properly layout video frame ***
        
        publisher.view.frame = CGRect(x: 0, y: 0, width: videoWidth, height: videoHeight)
        
        let publisherAudioButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        publisherAudioButton.backgroundColor = .redColor()
        publisherAudioButton.addTarget(self, action: #selector(togglePublisherMic), forControlEvents: .TouchUpInside)
        publisher.view.addSubview(publisherAudioButton)
        
        let frontCameraButton = UIButton(frame: CGRect(x: 105, y: 0, width: 100, height: 50))
        frontCameraButton.backgroundColor = .yellowColor()
        frontCameraButton.addTarget(self, action: #selector(toggleCameraPosition), forControlEvents: .TouchUpInside)
        publisher.view.addSubview(frontCameraButton)
    }
    
    func displaySubscriberViewWithSubscriber(subscriber: OTSubscriber) {
        
        if let view = subscriber.view {
            view.frame =  CGRect(x: 0, y: videoHeight, width: videoWidth, height: videoHeight)
            self.view.addSubview(view)
        }
        
        // TODO: autolayout buttons
        
        let subscriberAudioButton = UIButton(frame: CGRect(x: 205, y: 0, width: 100, height: 50))
        subscriberAudioButton.backgroundColor = .greenColor()
        subscriberAudioButton.addTarget(self, action: #selector(toggleSubscriberAudio), forControlEvents: .TouchUpInside)
        subscriber.view.addSubview(subscriberAudioButton)
    }
    
    
    // MARK: Actions
    
    func togglePublisherMic() {
        
//        publisher.publishAudio = !publisher.publishAudio
        
        // TODO: add button effects on controlstate change..
    }
    
    func toggleCameraPosition() {
        
//        if publisher!.cameraPosition == .Front {
//            publisher!.cameraPosition = .Back
//        } else {
//            publisher!.cameraPosition = .Front
//        }
    }
    
    func toggleSubscriberAudio() {
    
//        subscriber.subscribeToAudio = !subscriber.subscribeToAudio
        
        // TODO: add button effects on controlstate change..
    }


//    deinit{
//        print("VideoChatVC Deinit")
//    }
}
