//
//  MonitorMiddleware.swift
//  ReSwiftMonitor
//
//  Created by 大澤卓也 on 2018/02/01.
//  Copyright © 2018年 Takuya Ohsawa. All rights reserved.
//

import Foundation
import ReSwift

public struct Configuration {
    let host: String
    let port: Int
    public init(host: String = "localhost", port: Int = 8000) {
        self.host = host
        self.port = port
    }
    
    public var url: URL? {
        let urlInfo = String(format: "%@:%d/socketcluster", host, port)
        let urlString = String(format: "ws://%@/?transport=websocket", urlInfo)
        return URL(string: urlString)
    }
}

public struct MonitorMiddleware {
    public static func make(configuration: Configuration) -> Middleware<StateType> {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.qualityOfService = .default
        queue.isSuspended = true
        
        return { dispatch, fetchState in
            guard let url = configuration.url else {
                fatalError("不正なURL")
            }
            let client = ScClient.shared
            client.setWebSocket(with: url)
            client.connect()
            return { next in
                return { action in
                    next(action)
                    queue.isSuspended = !client.socket.isConnected
                    queue.addOperation(SendActionInfoOperation(state: fetchState()!, action: action, client: client))
                }
            }
        }
    }
}

fileprivate class SendActionInfoOperation: Operation {
    let state: StateType
    let action: Action
    unowned let client: ScClient
    
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
