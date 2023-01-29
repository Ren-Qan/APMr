//
//  HomepageInstrumentsModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/29.
//

import Foundation

struct PerformanceIndicator {
    var cpu = PerformanceCPUIndicator()
}

struct PerformanceCPUIndicator {
    var seconds: Int = 0
    var process: CGFloat = 0
    var total: CGFloat = 0
}
