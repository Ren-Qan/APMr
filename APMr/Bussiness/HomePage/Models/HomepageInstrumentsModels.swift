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

protocol PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { get }
}

struct PerformanceIndicator {
    var seconds: CGFloat = 0
    var cpu = PCPUIndicator()
    var gpu = PGPUIndicator()
    var fps = PFPSIndicator()
    var memory = PMemoryIndicator()
    var network = PNetworkIndicator()
    var io = PIOIndicator()
    var diagnostic = PDiagnosticIndicator()
}

struct PCPUIndicator: PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .cpu }
    var process: CGFloat = 0 // 0 - 100
    var total: CGFloat = 0 // 0 - 100
}

struct PMemoryIndicator: PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .memory }
    var resident: Int64 = 0
    var memory: Int64 = 0
    var vm: Int64 = 0
}

struct PFPSIndicator: PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .fps }
    var fps: CGFloat = 0
    var jank: Int = 0
    var bigJank: Int = 0
    var stutter: CGFloat = 0
}

struct PGPUIndicator: PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .gpu }
    var device: CGFloat = 0 // 0 - 100
    var renderer: CGFloat = 0 // 0 - 100
    var tiler: CGFloat = 0 // 0 - 100
}

struct PNetworkIndicator: PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .network }
    var down: CGFloat = 0
    var up: CGFloat = 0
}

struct PIOIndicator: PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .io }
    var read: CGFloat = 0 // MB
    var write: CGFloat = 0 // MB
}

struct PDiagnosticIndicator: PerformanceIndicatorProtocol {
    var type: PerformanceIndicatorType { .diagnostic }
    var amperage: CGFloat = 0 // mA
    var voltage: CGFloat = 0 // V
    var battery: CGFloat = 0 // 1 - 100
    var temperature: CGFloat = 0 // °C
}
