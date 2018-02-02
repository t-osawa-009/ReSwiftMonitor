//
//  LoggingMiddleware.swift
//  ReSwiftMonitor
//
//  Created by 大澤卓也 on 2018/02/01.
//  Copyright © 2018年 Takuya Ohsawa. All rights reserved.
//

import Foundation
import ReSwift

public struct LoggingMiddleware {
    
    public static func make(prefix: String) -> Middleware<StateType> {
        return { dispatch, fetchState in
            return { next in
                return { action in
                    // Action name
                    let type = Mirror(reflecting: action).subjectType
                    print(prefix + String(describing: type))
                    return next(action)
                }
            }
        }
    }
}

