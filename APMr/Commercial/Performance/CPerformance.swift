//
//  CPerformance.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import AppKit
import Combine

class CPerformance: ObservableObject {
    private lazy var metrics = DSPMetrics()
    private(set) lazy var event = Event()
    private(set) lazy var chart = Chart()
}

extension CPerformance {
    func interact(_ iEvent: IEventHandleView.IEvent) {
        event.sync(iEvent)
    }
    
    func start() {

    }
}
