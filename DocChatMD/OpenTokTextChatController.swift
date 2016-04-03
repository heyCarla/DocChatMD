//
//  OpenTokTextChatController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-30.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation

typealias MessageSentCompletion = (result: Result<String>) -> Void

final class OpenTokTextChatController: NSObject {
    
    private var messageSentCompletion: MessageSentCompletion?
    
    func sendChatMessageInSession(session: OTSession, message: String) {
        
        var openTokError : OTError?
        session.signalWithType("chat", string: message, connection: nil, error: &openTokError)
        
        if openTokError == nil {
            messageSentCompletion!(result: Result.failure(error: OTSessionError.SessionMessageNotSent))
        } else {
            messageSentCompletion!(result: Result.success(value: message))
        }
    }
}