//
//  MonitorMiddleware.swift
//  ReSwiftMonitor
//
//  Created by 大澤卓也 on 2018/02/01.
//  Copyright © 2018年 Takuya Ohsawa. All rights reserved.
//

import Foundation
import ReSwift

public struct MonitorMiddleware {
    public static func make() -> Middleware<StateType> {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        queue.isSuspended = true
        
        return { dispatch, fetchState in
            let host = "localhost"
            let port = 8000
            let urlInfo = String(format: "%@:%d/socketcluster", host, port)
            let urlString = String(format: "ws://%@/?transport=websocket", urlInfo)
            let client = ScClient(url: urlString)
            client.socket.disableSSLCertValidation = true
            client.connect()
            return { next in
                return { action in
                    queue.isSuspended = !client.socket.isConnected
                    queue.addOperation(SendActionInfoOperation(state: fetchState()!, action: action, client: client))
                    return next(action)
                }
            }
        }
    }
}

fileprivate class SendActionInfoOperation: Operation {
    let state: StateType
    let action: Action
    weak var client: ScClient!
    
    init(state: StateType, action: Action, client: ScClient) {
        self.state = state
        self.action = action
        self.client = client
    }
    
    override func main() {
        let serializedState = MonitorSerialization.convertValueToDictionary(self.state)
        var serializedAction = MonitorSerialization.convertValueToDictionary(self.action)
        
        if var _serializedAction = serializedAction as? [String: Any] {
            // add type to nicely show the action name in the UI
            _serializedAction["type"] = String(reflecting: type(of: self.action))
            serializedAction = _serializedAction
        }
        
        let data: [String: Any] = [
            "type": "ACTION",
            "id": self.client.counter.value,
            "action": [
                "action": serializedAction,
                "timestamp": Date().timeIntervalSinceReferenceDate
            ],
            "payload": serializedState ?? "No_state"
        ]
        
        client.emit(eventName: "log", data: data as AnyObject)
    }
}
