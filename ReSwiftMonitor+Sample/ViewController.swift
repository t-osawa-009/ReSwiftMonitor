//
//  ViewController.swift
//  ReSwiftMonitor+Sample
//
//  Created by 大澤卓也 on 2018/02/02.
//  Copyright © 2018年 Takuya Ohsawa. All rights reserved.
//

import UIKit
import ReSwift

class ViewController: UIViewController {
    
    @IBOutlet private weak var numberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        numberLabel.text = "0"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        store.unsubscribe(self)
    }
    
    @IBAction func mainasuButtonTapped(_ sender: UIButton) {
        store.dispatch(CounterAction.Decrease())
    }
    
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        store.dispatch(CounterAction.Increase())
    }
    
    @IBAction func mainasuEnumButtonTapped(_ sender: UIButton) {
        store.dispatch(CounterActionEnum.decrease(val: -1))
    }
    
    @IBAction func plusEnumButtonTapped(_ sender: UIButton) {
        store.dispatch(CounterActionEnum.decrease(val: 1))
    }
    
}

extension ViewController: StoreSubscriber {
    func newState(state: AppState) {
        numberLabel.text = "\(state.counter)"
    }
}
