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
    private(set) lazy var chart = Chart(metrics.syncModel)
    
    private var timer: Timer? = nil
}

extension CPerformance {
    func interact(_ iEvent: IEventHandleView.IEvent) {
        event.sync(iEvent)
        
        if iEvent.source.type == .scrollWheel {
            chart.offset(iEvent.source.deltaX)
        }
    }
    
    func start() {
        #if DEBUG
        if timer != nil {
            timer?.invalidate()
            timer = nil
            return
        }
        
        timer = Timer(timeInterval: 0.5, repeats: true, block: { [weak self] _ in
            self?.chart.addRandom(1)
        })
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
        #endif
    }
}
