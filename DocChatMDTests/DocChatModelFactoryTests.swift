//
//  DocChatModelFactoryTests.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-26.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import XCTest
@testable import DocChatMD

class DocChatModelFactoryTests: XCTestCase {
    
    let modelFactory = OpenTokSessionModelFactory()
    
    
    // MARK: Testing Session Id
    
    func testSessionIdWithValidData() {
        
        let validDict       = ["opentok_session_id": "90210"]
        let validSessionId  = modelFactory.openTokSessionIdWithData(validDict).value()
        
        XCTAssert(validSessionId != nil, "session id is generated from valid keys")
    }
    
    func testSessionIdWithInvalidSchemaData() {
        
        let invalidDict     = ["opentok_session_id": 90210]
        let sessionError    = modelFactory.openTokSessionIdWithData(invalidDict).error()!
        
        switch sessionError {
        case ParseError.UnexpectedType:
            break
        default:
            XCTFail("invalid ErrorType returned for invalid schema")
        }
    }
    
    func testSessionIdWithMissingKeyData() {
        
        let invalidDict     = ["wrongKey": 90210]
        let sessionError    = modelFactory.openTokSessionIdWithData(invalidDict).error()!
        
        switch sessionError {
        case ParseError.MissingKey(let missingKey):
            XCTAssert(missingKey == "opentok_session_id", "missing key should be 'opentok_session_id'")
        default:
            XCTFail("invalid ErrorType returned for missing key")
        }
    }
    
    
    // MARK: Testing Session Token
    
    func testSessionTokenWithValidData() {
        
        let validDict       = ["opentok_token": "10010"]
        let validSessionId  = modelFactory.openTokSessionTokenWithData(validDict).value()
        
        XCTAssert(validSessionId != nil, "session token is generated from valid keys")
    }
    
    func testSessionTokenWithInvalidSchemaData() {
        
        let invalidDict     = ["opentok_token": 10010]
        let sessionError    = modelFactory.openTokSessionTokenWithData(invalidDict).error()!
        
        switch sessionError {
        case ParseError.UnexpectedType:
            break
        default:
            XCTFail("invalid ErrorType returned for invalid schema")
        }
    }
    
    func testSessionTokenWithMissingKeyData() {
        
        let invalidDict     = ["wrongKey": 10010]
        let sessionError    = modelFactory.openTokSessionTokenWithData(invalidDict).error()!
        
        switch sessionError {
        case ParseError.MissingKey(let missingKey):
            XCTAssert(missingKey == "opentok_token", "missing key should be 'opentok_token'")
        default:
            XCTFail("invalid ErrorType returned for missing key")
        }
    }
    
    
    // MARK: Testing SessionModel
    
    func testSessionModelWithValidData() {
        
        let validSessionId      = "90210"
        let validToken          = "10010"
        let validSessionModel   = modelFactory.openTokSessionModelWithId(validSessionId, token: validToken)
        
        XCTAssert(validSessionModel.sessionId == validSessionId, "session model was created with the valid session id")
        XCTAssert(validSessionModel.token == validToken, "session model was created with the valid token")
    }
}