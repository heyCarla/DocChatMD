//
//  OpenTokSessionModel.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-28.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation

struct OpenTokSessionModel {
    
    let sessionId: String
    let token: String
    let apiKey = "45316542"
    
    init(sessionId: String, token: String) {
        
        self.sessionId  = sessionId
        self.token      = token
    }
}