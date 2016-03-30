//
//  OpenTokTextChatController.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-30.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation

final class OpenTokTextChatController: NSObject {
    
    func sendChatMessageInSession(session: OTSession, message: String) {
        
        var openTokError : OTError?
        session.signalWithType("chat", string: message, connection: nil, error: &openTokError)
        
        if let error = openTokError {
            // TODO: handle error as result
        } else {
            print("signal sent: \(message)")
        }
    }
}