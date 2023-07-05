//
//  CPerformance.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import AppKit
import Combine

class CPerformance: ObservableObject {
    private lazy var source = DSPMetrics()
    
    private(set) lazy var event = AEvent()
    private(set) lazy var chart = Chart()
    
    private var timer: Timer?    
}

extension CPerformance {
    func sync(event: IEventHandleView.IEvent) {
        self.event.sync(event)
    }
    
    func start() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            return
        }
        chart.clean()
        timer = Timer(timeInterval: 0.5, repeats: true, block: { [weak self] _ in
            self?.chart.sync()
        })
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
}
