//
//  HomepageChartModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/1.
//

import Cocoa

struct PerformanceChartModel {
    var models: [ChartModel]
    
    init() {
        models = [.init(title: "CPU",
                        type: .cpu,
                        series: [.init(value: "process"),
                                 .init(value: "total")]),
                  
                  .init(title: "GPU",
                        type: .gpu,
                        series: [.init(value: "device"),
                                 .init(value: "renderer"),
                                 .init(value: "tiler")]),
                  
                  .init(title: "Memory",
                        type: .memory,
                        series: [.init(value: "memory"),
                                 .init(value: "resident"),
                                 .init(value: "vm")]),
                  
                  .init(title: "Network",
                        type: .network,
                        series: [.init(value: "up"),
                                 .init(value: "down")]),
                  
                  .init(title: "FPS",
                        type: .fps,
                        series: [.init(value: "fps"),
                                 .init(value: "jank"),
                                 .init(value: "bigJank"),
                                 .init(value: "stutter")]),
                  
                  .init(title: "I/O",
                        type: .io,
                        series: [.init(value: "read"),
                                 .init(value: "write")]),
                  
                  .init(title: "Diagnostic",
                        type: .diagnostic,
                        series: [.init(value: "amperage"),
                                 .init(value: "voltage"),
                                 .init(value: "battery"),
                                 .init(value: "temperature")])]
    }
}

struct ChartModel: Identifiable {
    var id = UUID()
    var title: String
    var type: PerformanceIndicatorType
    var series: [ChartSeriesItem]
    var yRange: ClosedRange<Int> = 0 ... Int.max
    var visiable = true
}

struct ChartSeriesItem: Identifiable {
    var id = UUID()
    var value: String
    var visiable: Bool = true
    var landmarks: [ChartLandmarkItem] = []
}

struct ChartLandmarkItem: Identifiable {
    var id = UUID()
    var x: Int
    var y: Int
    var visiable = true
}
