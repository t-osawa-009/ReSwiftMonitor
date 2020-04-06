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
    let isSecureConnection: Bool
    public init(host: String = "localhost", port: Int = 8000, isSecureConnection: Bool = false) {
        self.host = host
        self.port = port
        self.isSecureConnection = isSecureConnection
    }
    
    public var url: URL? {
        let urlInfo: String = {
            if isSecureConnection {
                return String(format: "%@:%d", host, port)
            } else {
                return String(format: "%@:%d/socketcluster", host, port)
            }
        }()
        let urlString: String = {
            if isSecureConnection {
                return String(format: "wss://%@/?transport=websocket", urlInfo)
            } else {
                return String(format: "ws://%@/?transport=websocket", urlInfo)
            }
        }()
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
                fatalError("invalid url")
            }
            let client = ScClient(url: url)
            client.connect()
            return { next in
                return { action in
                    if !client.socket.isConnected {
                        client.connect()
                        return next(action)
                    }
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
            _serializedAction["type"] = typeString(action: self.action)
            serializedAction = _serializedAction
        }
        
        let soketID: String = {
            return client.socketId ?? ""
        }()
        
        let data: [String: Any] = [
            "type": "ACTION",
            "id": soketID,
            "action": [
                "action": serializedAction,
                "timestamp": Date().timeIntervalSinceReferenceDate
            ],
            "payload": serializedState ?? "No_state"
        ]
        
        client.emit(eventName: "log", data: data as AnyObject)
    }
    
    private func typeString(action: Action) -> String {
        let mirror = Mirror(reflecting: action)
        if mirror.displayStyle == .enum {
            let str = String(reflecting: action)
            if let firstSegment = str.split(separator: ":").first {
                return String(firstSegment) + "..."
            }
            return str
        }
        
        return String(reflecting: type(of: action))
    }
}

