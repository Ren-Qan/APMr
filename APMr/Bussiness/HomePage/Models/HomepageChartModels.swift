//
//  HomepageChartModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/1.
//

import Cocoa
import SwiftUI

class PerformanceChartModel: ObservableObject {
    @Published var models: [ChartModel]
    
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

class ChartModel: Identifiable, ObservableObject {
    var id = UUID()
    var title: String = ""
    var type: PerformanceIndicatorType
    var series: [ChartSeriesItem] = []
    var yAxis = Axis()
    var xAxis = Axis()
    @Published var visiable = true
    
    init(id: UUID = UUID(),
         title: String,
         type: PerformanceIndicatorType,
         series: [ChartSeriesItem],
         visiable: Bool = true) {
        self.id = id
        self.title = title
        self.type = type
        self.series = series
        self.visiable = visiable
    }
    
    var chartShowSeries: [ChartSeriesItem] {
        return series.filter { item in
            return item.visiable
        }
    }
}

class ChartSeriesItem: Identifiable, ObservableObject {
    var id = UUID()
    var value: String = ""
    var visiable: Bool = true
    var style: Color = .random
    var landmarks: [ChartLandmarkItem]
    
    init(id: UUID = UUID(),
         value: String,
         visiable: Bool = true,
         style: Color = .random,
         landmarks: [ChartLandmarkItem] = []) {
        self.id = id
        self.value = value
        self.visiable = visiable
        self.style = style
        self.landmarks = landmarks
    }
    
    func chartLandMarks(axis: Axis) -> [ChartLandmarkItem] {
        let count = landmarks.count
        let x = axis.start
        return Array(landmarks[x ..< count])
    }
}

struct ChartLandmarkItem: Identifiable {
    var id = UUID()
    var x: Int
    var y: Int
    var visiable = true
}

class Axis {
    var start: Int = 0
    var end: Int = 0
}
