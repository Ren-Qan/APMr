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
    
    private(set) lazy var hint = Hint()
    private(set) lazy var chart = {
        let chart = Chart()
        chart.preset(metrics.syncModel)
        return chart
    }()
    
    private var timer: Timer? = nil
}

extension CPerformance {
    func interact(_ iEvent: IEventHandleView.IEvent) {
        hint.sync(iEvent)
    }
    
    func start(_ phone: IDevice.P, _ app: IApp) {
        metrics.link(phone) { [weak self] state in
            if state {
                self?.monitor(app)
            }
        }
    }
    
    private func monitor(_ app: IApp) {
        metrics.monitor(app: app) { [weak self] state in
            self?.sample()
        }
    }
    
    private func sample() {
        chart.clean()
        hint.clean()
        
        timer?.invalidate()
        timer = nil
        
        timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            DispatchQueue.global().async {
                self?.metrics.sample { state in
                    switch state {
                        case .invalid:
                            break
                        case .success(let m):
                            self?.chart.sync(m)
                    }
                }
            }
        }
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
}
