//
//  AppState.swift
//  ReSwiftMonitor+Sample
//
//  Created by 大澤卓也 on 2018/02/02.
//  Copyright © 2018年 Takuya Ohsawa. All rights reserved.
//

import Foundation
import ReSwift

struct AppState: StateType {
    var counter: Int = 0

}

extension AppState {
    static func reducer() -> Reducer<AppState> {
        return { action, state in
            var state = state ?? AppState()
            
            switch action {
            case _ as CounterAction.Increase:
                state.counter += 1
            case _ as CounterAction.Decrease:
                state.counter -= 1
            case let action as CounterActionEnum:
                if case .decrease(let value) = action {
                    state.counter += value
                }
            default:
                break
            }
            
            return state
        }
    }
}
