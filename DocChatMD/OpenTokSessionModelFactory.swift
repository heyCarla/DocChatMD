//
//  OpenTokSessionModelFactory
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-26.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation

enum ParseError: ErrorType {
    
    case MissingKey(key: String)
    case UnexpectedType
}

struct OpenTokSessionModelFactory {
    
    
    // MARK: Session Id Method(s)
    
    func openTokSessionIdWithData(data: [String:AnyObject]) -> Result<String> {
        
        // get session id
        guard let _ = data["opentok_session_id"] else {
            print("no session key present -- fail")
            return Result.failure(error: ParseError.MissingKey(key: "opentok_session_id"))
        }
        
        guard let sessionId = data["opentok_session_id"] as? String else {
            print("failed to retrieve session id -- fail")
            return Result.failure(error: ParseError.UnexpectedType)
        }
        
        return Result.success(value: sessionId)
    }
    
    
    // MARK: Session Token Method(s)
    
    func openTokSessionTokenWithData(data: [String:AnyObject]) -> Result<String> {
        
        // get session token
        guard let _ = data["opentok_token"] else {
            print("no token present -- fail")
            return Result.failure(error: ParseError.MissingKey(key: "opentok_token"))
        }
        
        guard let token = data["opentok_token"] as? String else {
            print("failed to retrieve token -- fail")
            return Result.failure(error: ParseError.UnexpectedType)
        }
        
        return Result.success(value: token)
    }
    
    
    // MARK: Session Model Method(s)
    
    func openTokSessionModelWithId(sessionId: String, token: String) -> OpenTokSessionModel {
        
        return OpenTokSessionModel(sessionId: sessionId, token: token)
    }
}