//
//  HomepageChartModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/1.
//

import Cocoa
import SwiftUI

class PerformanceChartModel {
    var models: [ChartModel] = []
    var count: Int = 0
    
    private func reset(_ i: PerformanceIndicatorInterface) {
        var models = [ChartModel]()
        
        i.indicators.forEach { indicator in
            let series = indicator.values.compactMap { value in
                if value.chartEnable {
                    return ChartSeriesItem(value: value.name)
                }
                return nil
            }
            let model = ChartModel(type: indicator.type, series: series)
            models.append(model)
        }
        self.models = models
    }
    
    func add(_ i: PerformanceIndicatorInterface, _ xAxisMaxCount: Int) {
        if i.indicators.count != models.count {
            reset(i)
        }
        
        let count = models.count
        let dataCount = i.recordSecond.intValue + 1
        (0 ..< count).forEach { index in
            let model = models[index]
            let indicator = i.indicators[index]
            let len = indicator.values.count
            
            var xStart = dataCount - xAxisMaxCount
            if xStart < 0 {
                xStart = 0
            }
            let xEnd = xStart + xAxisMaxCount
            model.xAxis.start = xStart
            model.xAxis.end = xEnd
            
            var yMax = 10
            
            var offsetI = 0
            (0 ..< len).forEach { j in
                let value = indicator.values[j]
                if value.chartEnable {
                    let item = ChartLandmarkItem(x: i.recordSecond.intValue, y: value.value.intValue)
                    model.series[offsetI].landmarks.append(item)
                    if item.y > yMax {
                        yMax = item.y
                    }
                    offsetI += 1
                }
            }
            
            yMax = Int(CGFloat(yMax) / 0.8)
            if model.yAxis.end < yMax {
                model.yAxis.end = yMax
            }
        }
        
        self.count += 1
    }
    
    func reset() {
        count = 0
        models.forEach { model in
            model.series.forEach { series in
                series.landmarks = []
            }
            model.xAxis.reset()
            model.yAxis.reset()
        }
    }
}

class ChartModel: Identifiable, ObservableObject {
    var id = UUID()
    var type: PerformanceIndicatorType
    var series: [ChartSeriesItem] = []
    var yAxis = Axis()
    var xAxis = Axis()
    @Published var visiable = true
    
    init(id: UUID = UUID(),
         type: PerformanceIndicatorType,
         series: [ChartSeriesItem],
         visiable: Bool = true) {
        self.id = id
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
    var len: Int {
        return end - start
    }
    
    func reset() {
        start = 0
        end = 0
    }
}
