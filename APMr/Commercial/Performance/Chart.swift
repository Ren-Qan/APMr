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
        let models: [Model]
        
        
        
        private let map: [DSPMetrics.T : Model]
        
        init(_ m: DSPMetrics.M) {
            var map: [DSPMetrics.T : Model] = [:]
            
            self.models = m.all.compactMap { item in
                let model = Model(type: item.type)
                map[item.type] = model
                return model
            }
            
            self.map = map
        }
        
        public func sync(_ model: DSPMetrics.M) {
            
        }
    
        #if DEBUG
        
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
        
        public func offset(_ delta: CGFloat) {
            models.forEach { model in
                model.line.offset += delta
                model.line.objectWillChange.send()
            }
        }
        
        #endif
    }
}

extension CPerformance.Chart {
    struct Model: Identifiable {
        var id: DSPMetrics.T { type }
        let type: DSPMetrics.T
        
        let line = Line()
        let axis = Axis()
        
        init(type: DSPMetrics.T) {
            self.type = type
        }
    }
}

// Line
extension CPerformance.Chart.Model {
    class Line: ObservableObject {
        fileprivate(set) var offset: CGFloat = 0
        fileprivate(set) var series: [Series] = []
        fileprivate(set) var visible: Bool = true
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
