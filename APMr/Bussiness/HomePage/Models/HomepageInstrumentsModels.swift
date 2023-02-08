//
//  HomepageInstrumentsModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/29.
//

import Foundation

enum PerformanceIndicatorType {
    case cpu
    case gpu
    case fps
    case memory
    case network
    case io
    case diagnostic
}

class PerformanceIndicator {
    var seconds: CGFloat = 0
    let cpu = PCPUIndicator()
    let gpu = PGPUIndicator()
    let fps = PFPSIndicator()
    let memory = PMemoryIndicator()
    let network = PNetworkIndicator()
    let io = PIOIndicator()
    let diagnostic = PDiagnosticIndicator()    
}

protocol PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { get }
}

class PBaseIndicator {

}

class PCPUIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .cpu }
    var process: CGFloat = 0 // 0 - 100
    var total: CGFloat = 0 // 0 - 100
}

class PMemoryIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .memory }
    var resident: CGFloat = 0 // MB
    var memory: CGFloat = 0 // MB
    var vm: CGFloat = 0 // GB
}

class PFPSIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .fps }
    var fps: CGFloat = 0
    var jank: Int = 0
    var bigJank: Int = 0
    var stutter: CGFloat = 0
}

class PGPUIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .gpu }
    var device: CGFloat = 0 // 0 - 100
    var renderer: CGFloat = 0 // 0 - 100
    var tiler: CGFloat = 0 // 0 - 100
}

class PNetworkIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .network }
    var downDelta: CGFloat = 0 //KB/s
    var upDelta: CGFloat = 0 // KB/s
}

class PIOIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .io }
    var read: CGFloat = 0 // KB
    var write: CGFloat = 0 // KB
    var readDelta: CGFloat = 0 // KB/s
    var writeDelta: CGFloat = 0 // KB/s
}

class PDiagnosticIndicator: PBaseIndicator, PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .diagnostic }
    var amperage: CGFloat = 0 // mA
    var voltage: CGFloat = 0 // V
    var battery: CGFloat = 0 // 1 - 100
    var temperature: CGFloat = 0 // °C
}
