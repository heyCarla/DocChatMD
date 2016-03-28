//
//  OperationResultWrapper.swift
//  DocChatMD
//
//  Created by Carla Alexander on 2016-03-28.
//  Copyright © 2016 MagicNoodles. All rights reserved.
//

import Foundation

enum Result<T> {
    
    case success(value: T)
    case failure(error: ErrorType)
    
    func value() -> T? {
        
        switch self {
        case .success(let resultValue):
            return resultValue
        default:
            return nil
        }
    }
    
    func error() -> ErrorType? {
        
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}