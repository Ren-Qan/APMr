//
//  CPerformance.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import AppKit
import Combine

class CPerformance: ObservableObject {
    private(set) lazy var chart = {
        let chart = Chart()
        chart.preset(metrics.syncModel)
        return chart
    }()
    
    private lazy var metrics = DSPMetrics()
    private var timer: Timer? = nil
    
    @Published var sampleCount = 0
}

extension CPerformance {
    func stop() {
        timer?.invalidate()
        timer = nil
        
        metrics.stop()
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
        sampleCount = 0
        
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
                            self?.sampleCount += 1
                    }
                }
            }
        }
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
}

#if DEBUG

extension CPerformance {
    func Debug_sample() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
            return
        }
        
        chart.clean()
        sampleCount = 0
        
        timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            DispatchQueue.global().async {
                self?.chart.addRandom(3)
                self?.sampleCount += 3
            }
        }
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
}

#endif
