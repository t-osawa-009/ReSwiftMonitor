//
//  JSONStringify.swift
//  ReSwiftMonitor
//
//  Created by 大澤卓也 on 2018/02/06.
//  Copyright © 2018年 Takuya Ohsawa. All rights reserved.
//

import Foundation

class JSON {
    class func stringify(value: AnyObject, prettyPrinted: Bool = true) -> String {
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : nil
        if JSONSerialization.isValidJSONObject(value) {
            if let data = try? JSONSerialization.data(withJSONObject: value, options: options!) {
                
                if let string = String(data: data, encoding: .utf8) {
                    return string
                }
            }
        }
        return ""
    }
}
