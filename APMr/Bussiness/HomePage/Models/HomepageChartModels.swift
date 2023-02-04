//
//  HomepageChartModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/1.
//

import Charts
import Cocoa
import SwiftUI

struct ChartD {
    var version = 0
    var models: [ChartModel] = []
    
    init() {
        func set(_ title: String, _ color: Color = .random) -> LineChartDataSet {
            let set = LineChartDataSet()
            set.drawCirclesEnabled = false
            set.mode = .cubicBezier
            set.highlightColor = .white
            set.highlightLineDashLengths = [1, 2]
            set.colors = [NSColor(color)]
            set.label = title
            return set
        }
        
        models = [
            .init(title: "CPU",
                  type: .cpu,
                  sets: [set("process"),
                         set("total")]),
            .init(title: "GPU",
                  type: .gpu,
                  sets: [set( "device"),
                         set( "renderer"),
                         set( "tiler")]),
            .init(title: "Memory",
                  type: .memory,
                  sets: [set( "memory"),
                         set( "resident"),
                         set( "vm")]),
            .init(title: "Network",
                  type: .network,
                  sets: [set( "up"),
                         set( "down")]),
            .init(title: "FPS",
                  type: .fps,
                  sets: [set( "fps"),
                         set( "jank"),
                         set( "bigJank"),
                         set( "stutter")]),
            .init(title: "I/O",
                  type: .io,
                  sets: [set( "read"),
                         set( "write")]),
            
                .init(title: "Diagnostic",
                      type: .diagnostic,
                      sets: [set( "amperage"),
                             set( "voltage"),
                             set( "battery"),
                             set( "temperature")])
        ]
    }
}

class ChartModel: Identifiable, ObservableObject {
    var id = UUID()
    var visiable = true
    var title: String
    var type: PerformanceIndicatorType
    var sets: [LineChartDataSet]
    var chartData: LineChartData
    
    init(id: UUID = UUID(),
         visiable: Bool = true,
         title: String,
         type: PerformanceIndicatorType,
         sets: [LineChartDataSet]) {
        self.id = id
        self.visiable = visiable
        self.title = title
        self.type = type
        self.sets = sets
        self.chartData = LineChartData(dataSets: sets)
    }
}
