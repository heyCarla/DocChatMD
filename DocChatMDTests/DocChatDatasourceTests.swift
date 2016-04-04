//
//  DocChatDatasourceTests.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-26.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import XCTest
@testable import DocChatMD

class DocChatDatasourceTests: XCTestCase {
    
    // datasource integration test
    func testAkiraDatasourceRequest() {
        
        let expectation = expectationWithDescription("OpenTok data completion")
        
        let akiraDatasource = AkiraDatasource()
        akiraDatasource.openTokSessionIdRequest { (result) in
            
            if let _ = result.value() {
                expectation.fulfill()
            } else {
                XCTFail()
            }
        }
        
        waitForExpectationsWithTimeout(5, handler: nil)
    }
}