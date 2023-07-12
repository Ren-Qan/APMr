//
//  Chart.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import AppKit
import Combine

extension CPerformance {
    class Chart {
        private var models: [Model] = []
        private var chartMap: [DSPMetrics.T : Model] = [:]
                            
        public func sync(_ model: DSPMetrics.M) {

        }
    }
}

extension CPerformance.Chart {
    private func cpu(_ model: DSPMetrics.M.CPU) {
        if chartMap[.CPU] == nil {
            chartMap[.CPU] = Model(type: .CPU).set(2)
        }
    }
    
    private func gpu(_ model: DSPMetrics.M.GPU) {
        if chartMap[.GPU] == nil {
            chartMap[.GPU] = Model(type: .GPU).set(3)
        }
    }
    
    private func fps(_ model: DSPMetrics.M.FPS) {
        if chartMap[.FPS] == nil {
            chartMap[.FPS] = Model(type: .FPS).set(1)
        }
    }
    
    private func memory(_ model: DSPMetrics.M.Memory) {
        if chartMap[.Memory] == nil {
            chartMap[.Memory] = Model(type: .Memory).set(3)
        }
    }
    
    private func io(_ model: DSPMetrics.M.IO) {
        if chartMap[.IO] == nil {
            chartMap[.IO] = Model(type: .IO).set(4)
        }
    }
    
    private func network(_ model: DSPMetrics.M.Network) {
        if chartMap[.Network] == nil {
            chartMap[.Network] = Model(type: .Network).set(4)
        }
    }
    
    private func diagnostic(_ model: DSPMetrics.M.Diagnostic) {
        if chartMap[.Diagnostic] == nil {
            chartMap[.Diagnostic] = Model(type: .Diagnostic).set(4)
        }
    }
}

#if DEBUG
extension CPerformance.Chart {
    public func addRandom(_ count: Int) {
        if let count = models.first?.line.series.count, count == 0 {
            models.forEach { model in
                model.line.series.removeAll()
                let count = 1
                (0 ..< count).forEach { _ in
                    model.line.series.append(.init())
                }
            }
        }
        
        
        (0 ..< count).forEach { i in
            models.forEach { model in
                model.line.series.forEach { series in
                    let x = CGFloat(series.landmarks.count)
                    series.landmarks.append(.init(x: x, y: .random(in: 0 ..< 100)))
                }
            }
        }
        
        models.forEach { model in
            model.line.objectWillChange.send()
        }
    }
}
#endif

extension CPerformance.Chart {
    struct Model: Identifiable {
        var id: DSPMetrics.T { type }
        let type: DSPMetrics.T
        
        let line = Line()
        let axis = Axis()
        
        init(type: DSPMetrics.T) {
            self.type = type
        }
        
        func set(_ seriesCount: Int) -> Self {
            line.set(seriesCount)
            return self
        }
    }
}

// Line
extension CPerformance.Chart.Model {
    class Line: ObservableObject {
        fileprivate(set) var series: [Series] = []
        fileprivate(set) var visible: Bool = true
        
        func set(_ count: Int) {
            series.removeAll()
            (0 ..< count).forEach { _ in
                series.append(Series())
            }
        }
    }
}

extension CPerformance.Chart.Model.Line {
    class Series: Identifiable {
        fileprivate(set) var landmarks: [Landmark] = []
        fileprivate(set) var visible: Bool = true
        
        let style: NSColor = .random
    }
    
    struct Landmark {
        var x: Double
        var y: Double
    }
}

// Axis
extension CPerformance.Chart.Model {
    class Axis: ObservableObject {
        struct A {
            var upper: Double = 0
            var lower: Double = 0
        }
        
        private(set) var x = A()
        private(set) var y = A()
    }
}
