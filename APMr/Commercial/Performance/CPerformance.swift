//
//  CPerformance.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import AppKit
import Combine

class CPerformance: ObservableObject {
    private lazy var event = AEvent()
    private lazy var source = DSPMetrics()
    
    private(set) lazy var chart = Chart()
    
    private var timer: Timer?
}

extension CPerformance {
    func sync(event: NSEvent) {
        
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

extension CPerformance {
    enum E {
        case cpu
        case gpu
        case fps
        case memory
        case network
        case io
        case diagnostic
        
        var name: String {
            switch self {
                case .memory:
                    return "Memory"
                case .network:
                    return "Network"
                case .io:
                    return "I/O"
                case .diagnostic:
                    return "Diagnostic"
                default:
                    return "\(self)".uppercased()
            }
        }
    }
}
