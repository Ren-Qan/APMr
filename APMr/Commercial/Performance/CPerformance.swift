//
//  CPerformance.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import AppKit
import SwiftUI

class CPerformance: ObservableObject {
    private(set) lazy var chart = {
        let chart = Chart()
        chart.preset(metrics.syncModel)
        return chart
    }()
    
    private lazy var metrics = DSPMetrics()
    private var timer: Timer? = nil

    private(set) static var interval: TimeInterval = 0.5
    private(set) var isSampling = false
    private var isLinking = false
    
    @Published var sampleCount = 0
    @Published var isNeedShowDetailSide = true
}

extension CPerformance {
    func stop() {
        timer?.invalidate()
        timer = nil
        
        metrics.stop()
    }
    
    func start(_ phone: IDevice.P,
               _ app: IApp,
               _ closure: @escaping (Bool) -> Void) {
        if isSampling { return }
        if isLinking { return }
        
        self.isLinking = true
        self.fire(phone, app) { [weak self] state in
            self?.isSampling = state
            self?.isLinking = false
            closure(state)
        }
    }
    
    private func fire(_ phone: IDevice.P,
                      _ app: IApp,
                      _ closure: @escaping (Bool) -> Void) {
        metrics.link(phone) { [weak self] state in
            guard state else {
                closure(false)
                return
            }
            
            self?.metrics.monitor(app: app) { state in
                guard state else {
                    closure(false)
                    return
                }
                self?.sample()
                closure(true)
            }
        }
    }
    
    private func sample() {
        chart.clean()
        sampleCount = 0
        
        timer?.invalidate()
        timer = nil
        
        let interval = CPerformance.interval
        timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            DispatchQueue.global().async {
                self?.metrics.sample { state in
                    switch state {
                        case .invalid:
                            break
                        case .success(let m):
                            let timing = interval * TimeInterval(self?.sampleCount ?? 0)
                            self?.chart.sync(m, timing)
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
            isSampling = false
            return
        }
        
        chart.clean()
        sampleCount = 0
        isSampling = true
        let interval = CPerformance.interval
        timer = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            DispatchQueue.global().async {
                (0 ..< 5).forEach { _ in
                    let timing = interval * TimeInterval(self?.sampleCount ?? 0)
                    self?.chart.addRandom(timing)
                    self?.sampleCount += 1
                }
            }
        }
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
}

#endif
