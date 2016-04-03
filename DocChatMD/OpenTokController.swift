//
//  OpenTokController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-29.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation

enum OTSessionError: ErrorType {

    case InvalidSession
    case PublisherNotFound
    case PublisherNotCreated
    case SubscriberNotFound
    case SessionMessageNotSent
}

typealias SessionCompletion             = (result: Result<OTSession>) -> Void
typealias MessageReceivedClosure        = (message: String?, isLocal: Bool) -> Void
typealias RemoveSubscriberCompletion    = (result: Result<OTSession>) -> Void
typealias EndSessionCompletion          = (result: Result<OTSession>) -> Void

final class OpenTokController: NSObject, OTSessionDelegate, OTSubscriberKitDelegate, OTPublisherDelegate {
    
    private var session: OTSession?
    private var publisher: OTPublisher?
    private var subscriber: OTSubscriber?
    private let subscribeToSelf = false
    private var sessionConnectionCompletion: SessionCompletion?
    private var removeSubscriberCompletion: RemoveSubscriberCompletion?
    private var endSessionCompletion: EndSessionCompletion?
    var messageReceivedClosure: MessageReceivedClosure?

    // error alerts
    private var controllerView: UIViewController?
    
    func connectToOTSessionFromController(controller: UIViewController, completion: SessionCompletion) {
        
        sessionConnectionCompletion = completion
        
        _ = AkiraDatasource().openTokSessionIdRequest({ (sessionModel) in
            
            let model       = sessionModel.value()
            let newSession  = OTSession(apiKey: model!.apiKey, sessionId: model!.sessionId, delegate: self)
            
            if let currentSession = newSession  {
            
                self.session = currentSession
                var openTokError: OTError?
                currentSession.connectWithToken(model!.token, error: &openTokError)
                
                if let error = openTokError {
                    
                    if self.controllerView == controller {
                        self.displayAlertViewWithOTError(error)
                    }
                }
            }
        })
    }
    
    // create instance of OTPublisher
    func createOTPublisher() -> Result<OTPublisher> {
        
        guard let publisher = OTPublisher(delegate: self) else {
            
            return Result.failure(error: OTSessionError.PublisherNotFound)
        }
        
        return Result.success(value: publisher)
    }
    
    func addPublisherToSession(session: OTSession, publisher: OTPublisher) {
        
        var openTokError : OTError?
        session.publish(publisher, error: &openTokError)
        
        if let error = openTokError {
            displayAlertViewWithOTError(error)
        }
    }
    
    // create instance of OTSubscriber
    private func startSubscriberOfStream(stream: OTStream) -> Result<OTSubscriber> {
        
        guard let subscriber = OTSubscriber(stream: stream, delegate: self) else {
            
            return Result.failure(error: OTSessionError.SubscriberNotFound)
        }
        
        return Result.success(value: subscriber)
    }
    
    private func addSubscriberToSession(session: OTSession, subscriber: OTSubscriber) {
        
        var openTokError : OTError?
        session.subscribe(subscriber, error: &openTokError)
        
        if let error = openTokError {
            displayAlertViewWithOTError(error)
        }
    }

    // remove subscriber
    private func removeSubscriberFromSession(session: OTSession) {
        
        guard let subscriberToRemove = self.subscriber else {
            
            removeSubscriberCompletion?(result: Result.failure(error: OTSessionError.SubscriberNotFound))
            removeSubscriberCompletion = nil
            return
        }
        
        var openTokError : OTError?
        session.unsubscribe(subscriber, error: &openTokError)
        
        if let error = openTokError {
            displayAlertViewWithOTError(error)
        }
        
        subscriberToRemove.view.removeFromSuperview()
        self.subscriber = nil
    }
    
    func endCurrentOTSession(session: OTSession?) {
        
        guard let currentSession = session  else {
            
            endSessionCompletion?(result: Result.failure(error: OTSessionError.InvalidSession))
            endSessionCompletion = nil
            return
        }
        
        currentSession.disconnect()
    }
    
    
    // MARK: AlertView
    
    private func displayAlertViewWithOTError(error: OTError) {
        
        let sessionAlertTitle   = "Video Chat Session Error"
        let actionTitle         = "OK"

        let alert = UIAlertController(title: sessionAlertTitle, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: actionTitle, style: UIAlertActionStyle.Default, handler: { action in
            
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        
        alert.addAction(okAction)
        self.controllerView!.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // MARK: OTSession Delegate Method(s)
    
    func sessionDidConnect(session: OTSession!) {
        
        // only run sessionConnectionCompletion once
        sessionConnectionCompletion?(result: Result.success(value: session))
        sessionConnectionCompletion = nil
    }
    
    func sessionDidDisconnect(session: OTSession!) {
    }
    
    func session(session: OTSession!, streamCreated stream: OTStream!) {
        
        if subscriber == nil && !subscribeToSelf {
            
            startSubscriberOfStream(stream)
            addSubscriberToSession(session, subscriber: subscriber!)
        }
    }
    
    func session(session: OTSession, streamDestroyed stream: OTStream) {
        
        if subscriber?.stream.streamId == stream.streamId {
            removeSubscriberFromSession(session)
        }
    }
    
    func session(session: OTSession, connectionCreated connection : OTConnection) {
    }
    
    func session(session: OTSession, connectionDestroyed connection : OTConnection) {
    }
    
    func session(session: OTSession, didFailWithError error: OTError) {
    }
    
    // chat-specific session delegate method
    func session(session: OTSession!, receivedSignalType type: String!, fromConnection connection: OTConnection!, withString string: String!) {
        
        // log messages sent to the user (isLocalClient)
        var isLocalClient = false
        
        if connection.connectionId == session.connection.connectionId {
            isLocalClient = true
        }
        
        messageReceivedClosure?(message: string, isLocal: isLocalClient)
    }
    
    
    // MARK: OTSubcsriberDelegate Method(s)
    
    func subscriberDidConnectToStream(subscriberKit: OTSubscriberKit) {
        
        let videoChatController = VideoChatViewController()
        videoChatController.displaySubscriberViewWithSubscriber(self.subscriber!)
    }
    
    func subscriber(subscriber: OTSubscriberKit, didFailWithError error : OTError) {
    }
    
    
    // MARK: OTPublisherDelegate Method(s)
    
    func publisher(publisher: OTPublisherKit, streamCreated stream: OTStream) {

        if subscriber == nil && subscribeToSelf {
            startSubscriberOfStream(stream)
        }
    }
    
    func publisher(publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        
        if subscriber?.stream.streamId == stream.streamId {
            removeSubscriberFromSession(stream.session)
        }
    }
    
    func publisher(publisher: OTPublisherKit, didFailWithError error: OTError) {
    }
}