//
//  OpenTokController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-29.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation

typealias SessionCompletion = (session: OTSession?) -> Void

final class OpenTokController: NSObject, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate {
    
    var session: OTSession?
//    var publisher: OTPublisher?
    var subscriber: OTSubscriber?
    let subscribeToSelf = false
    private var sessionConnectionCompletion: SessionCompletion?
    
    func connectToOTSession(completion: SessionCompletion) {
        
        sessionConnectionCompletion = completion
        
        _ = AkiraDatasource().openTokSessionIdRequest({ (sessionModel) in
            
            let model       = sessionModel.value()
            self.session    = OTSession(apiKey: model!.apiKey, sessionId: model!.sessionId, delegate: self)
            
            if let session = self.session {
                
                var openTokError: OTError?
                session.connectWithToken(model!.token, error: &openTokError)
                
                if let error = openTokError {
                    
                    // TODO: handle error as result
                }
            }
        })
    }
    
    // create instance of OTPublisher
    func createOTPublisher() -> OTPublisher? {
        
        guard let publisher = OTPublisher(delegate: self) else {
            
            // TODO: add error/result type
            return nil
        }
        
        return publisher
    }
    
    func addPublisherToSession(session: OTSession, publisher: OTPublisher) {
        
        var openTokError : OTError?
        session.publish(publisher, error: &openTokError)
        
        if let error = openTokError {
            // TODO: handle error as result
        }
    }
    
    // create instance of OTSubscriber
    func startSubscriberOfStream(stream: OTStream) -> OTSubscriber? {
        
        guard let subscriber = OTSubscriber(stream: stream, delegate: self) else {
            
            // TODO: handle result/error
            return nil
        }
        
        return subscriber
    }
    
    func addSubscriberToSession(session: OTSession, subscriber: OTSubscriber) {
        
        var openTokError : OTError?
        session.subscribe(subscriber, error: &openTokError)
        
        if let error = openTokError {
            // TODO: handle error as result
        }
    }
    
    // remove subscriber
    func removeSubscriberFromSession(session: OTSession) {
        
        if let subscriber = self.subscriber {
            
            var openTokError : OTError?
            session.unsubscribe(subscriber, error: &openTokError)
            
            if let error = openTokError {
                // TODO: handle error as result
            }
            
            subscriber.view.removeFromSuperview()
            self.subscriber = nil
        }
    }
    
    // MARK: OTSession Delegate Method(s)
    
    func sessionDidConnect(session: OTSession!) {
        
        // only run sessionConnectionCompletion once
        sessionConnectionCompletion?(session: session)
        sessionConnectionCompletion = nil
        print("session connected: \(session)")
    }
    
    func sessionDidDisconnect(session: OTSession!) {
        print("session disconnected: \(session)")
    }
    
    func session(session: OTSession!, streamCreated stream: OTStream!) {
        
        print("session stream created (\(stream.streamId))")
        
        if subscriber == nil && !subscribeToSelf {
            startSubscriberOfStream(stream)
            addSubscriberToSession(session, subscriber: subscriber!)
        }
    }
    
    func session(session: OTSession, streamDestroyed stream: OTStream) {
        
        print("session stream destroyed (\(stream.streamId))")
        
        if subscriber?.stream.streamId == stream.streamId {
            removeSubscriberFromSession(session)
        }
    }
    
    func session(session: OTSession, connectionCreated connection : OTConnection) {
        print("session connectionCreated (\(connection.connectionId))")
    }
    
    func session(session: OTSession, connectionDestroyed connection : OTConnection) {
        print("session connectionDestroyed (\(connection.connectionId))")
    }
    
    func session(session: OTSession, didFailWithError error: OTError) {
        print("session didFailWithError (%@)", error)
    }
    
    
    // MARK: OTSubcsriberDelegate Method(s)
    
    func subscriberDidConnectToStream(subscriberKit: OTSubscriberKit) {
        print("subscriberDidConnectToStream (\(subscriberKit))")
        
        let videoChatController = VideoChatViewController()
        videoChatController.displaySubscriberViewWithSubscriber(self.subscriber!)
    }
    
    func subscriber(subscriber: OTSubscriberKit, didFailWithError error : OTError) {
        print("subscriber %@ didFailWithError %@", subscriber.stream.streamId, error)
    }
    
    
    // MARK: OTPublisherDelegate Method(s)
    
    func publisher(publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("publisher streamCreated %@", stream)
        
        // Step 3b: (if YES == subscribeToSelf): Our own publisher is now visible to
        // all participants in the OpenTok session. We will attempt to subscribe to
        // our own stream. Expect to see a slight delay in the subscriber video and
        // an echo of the audio coming from the device microphone.
        if subscriber == nil && subscribeToSelf {
            startSubscriberOfStream(stream)
        }
    }
    
    func publisher(publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        print("publisher streamDestroyed %@", stream)
        
        if subscriber?.stream.streamId == stream.streamId {
            removeSubscriberFromSession(stream.session)
        }
    }
    
    func publisher(publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("publisher didFailWithError %@", error)
    }
}