//
//  Serialization.swift
//  ReSwiftMonitor
//
//  Created by 大澤卓也 on 2018/02/01.
//  Copyright © 2018年 Takuya Ohsawa. All rights reserved.
//

import Foundation

protocol Monitorable {
    var monitorValue: Any { get }
}

extension Monitorable {
    var monitorValue: Any { return self }
}

extension String: Monitorable {}
extension Int: Monitorable {}
extension CGFloat: Monitorable {}
extension Double: Monitorable {}

extension Array: Monitorable {
    var monitorValue: Any {
        return self.map { MonitorSerialization.convertValueToDictionary($0) }
    }
}

extension Dictionary: Monitorable {
    var monitorValue: Any {
        var monitorDict: [String: Any] = [:]
        
        for (key, value) in self {
            monitorDict["\(key)"] = MonitorSerialization.convertValueToDictionary(value)
        }
        
        return monitorDict
    }
}

struct MonitorSerialization {
    private init() {}
    
    static func convertValueToDictionary(_ value: Any) -> Any? {
        if let v = value as? Monitorable {
            return v.monitorValue
        }
        
        let mirror = Mirror(reflecting: value)
        guard mirror.displayStyle == .struct ||
            mirror.displayStyle == .enum else {
                return String(reflecting: value)
        }
        
        var result: [String: Any] = [:]
        
        for (key, child) in mirror.children {
            guard let key = key else {
                continue
            }
            
            result[key] = MonitorSerialization.convertValueToDictionary(child)
        }
        
        return result
    }
}
