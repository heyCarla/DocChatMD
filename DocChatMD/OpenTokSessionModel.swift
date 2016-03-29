//
//  OpenTokSessionModel.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-28.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation

struct OpenTokSessionModel {
    
    let sessionId = "2_MX40NTMxNjU0Mn5-MTQ1OTIzMjg5ODI5MH41WWtrSzFNdVg3NEZhYUVlYW9ybjAyc3R-UH4" // hard-coded session id as per code test requirements
    let token: String
    let apiKey = "45316542"
    
    init(sessionId: String, token: String) {
        
//        self.sessionId  = sessionId
        self.token      = token
    }
}