//
//  CounterAction.swift
//  ReSwiftMonitor+Sample
//
//  Created by 大澤卓也 on 2018/02/02.
//  Copyright © 2018年 Takuya Ohsawa. All rights reserved.
//

import Foundation
import ReSwift

struct CounterAction {
    struct Increase: Action {}
    struct Increase2: Action {
        let value: Int
    }
    struct Decrease: Action {}
    struct Decrease2: Action {
        let value: Int
    }
}

enum CounterActionEnum: Action {
    case decrease(val: Int)
}
