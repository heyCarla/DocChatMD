//
//  AkiraDatasource.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-26.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation

enum DatasourceError: ErrorType {
    
    case NetworkRequestFailure(error: NSError)
    case UnexpectedAPIResponse
}

typealias AkiraDatasourceResponseCompletion = (result: Result<[String:AnyObject]>) -> Void
typealias OpenTokSessionModelCompletion     = (result: Result<OpenTokSessionModel>) -> Void

struct AkiraDatasource {
    
    let sessionsURL = "http://challenge-api.akira.md:9292/v1/opentok/sessions"
    
    func openTokSessionIdRequest(completion: OpenTokSessionModelCompletion) {
        
        // get OpenTok session id from sessions endpoint
        makeDatasourceRequest(sessionsURL, httpMethod: "POST") { (dataResult) in
           
            switch dataResult {
            case .success(let data):
                
                let sessionResult = OpenTokSessionModelFactory().openTokSessionIdWithData(data)
        
                guard let sessionId = sessionResult.value() else {
                    
                    // force unwrapped error because it's impossible for it to be nil in this Result where the value is nil
                    completion(result: .failure(error: sessionResult.error()!))
                    return
                }
                
                // for the purposes of this test, using hard-coded session id as mentioned in requirements
                let hardcodedSessionId = "2_MX40NTMxNjU0Mn5-MTQ1OTIzMjg5ODI5MH41WWtrSzFNdVg3NEZhYUVlYW9ybjAyc3R-UH4"
                
                self.requestOpenTokSessionTokenWithSessionId(hardcodedSessionId, completion: { (dataResult) in
                    
                    switch dataResult {
                    case .success(let data):
                        
                        guard let sessionToken = OpenTokSessionModelFactory().openTokSessionTokenWithData(data).value() else {
                            
                            // force unwrapped error because it's impossible for it to be nil in this Result where the value is nil
                            completion(result: .failure(error: dataResult.error()!))
                            return
                        }
                        
                        let sessionModel = OpenTokSessionModelFactory().openTokSessionModelWithId(sessionId, token: sessionToken)
                        
                        completion(result: Result.success(value: sessionModel))
                        
                    case .failure(let error):
                        print(error)
                        completion(result: Result.failure(error: error))
                    }
                    
                })
                
            case .failure(let error):
                print(error)
                completion(result: Result.failure(error: error))
            }
        }
    }
    
    private func requestOpenTokSessionTokenWithSessionId(sessionId: String, completion: AkiraDatasourceResponseCompletion) {

        // get OpenTok token from tokens endpoint
        let url = "\(sessionsURL)/" + "\(sessionId)/tokens"
        makeDatasourceRequest(url, httpMethod: "POST") { (tokenResult) in
            
            completion(result: tokenResult)
        }
    }
    
    
    // MARK: Request Method(s)
    
    private func makeDatasourceRequest(url: String, httpMethod: String, completion: AkiraDatasourceResponseCompletion) {
        
        let request         = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod  = httpMethod
        
        let session     = NSURLSession(configuration: .defaultSessionConfiguration())
        let dataTask    = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            if let error = error {
               
                dispatch_async(dispatch_get_main_queue(), {
                    completion(result: Result.failure(error: DatasourceError.NetworkRequestFailure(error: error)))
                })
            }
            
            guard let jsonData = data else {
                
                print("no data -- fail")
                dispatch_async(dispatch_get_main_queue(), {
                    completion(result: Result.failure(error: DatasourceError.UnexpectedAPIResponse))
                })
                
                return
            }
            
            guard let dataDictionary = try? NSJSONSerialization.JSONObjectWithData(jsonData, options: .MutableContainers) as! [String: AnyObject] else {
                
                print("unexpected data received -- fail")
                completion(result: Result.failure(error: DatasourceError.UnexpectedAPIResponse))
                
                return
            }
            
            completion(result: Result.success(value: dataDictionary))
        }
        
        dataTask.resume()
    }
}