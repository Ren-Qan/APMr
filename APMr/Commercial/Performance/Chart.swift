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
        let models: [M]

        var x: Double = 0
        
        init() {
            let values: [E] = [.cpu, .gpu, .fps, .memory, .network, .io, .diagnostic]
            models = values.compactMap { M(id: $0) }
        }
        
        func clean() {
            x = 0
            models.forEach { model in
                model.series.forEach { series in
                    series.landmarks = []
                }
                model.objectWillChange.send()
            }
        }
        
        func sync() {
            let x = self.x + 1
            self.x = x
            models.forEach { model in
                model.series.forEach { series in
                    series.landmarks.append(.init(x: x, value: .random(in: 0 ..< 100)))
                }
                model.objectWillChange.send()
            }
        }
    }
}

extension CPerformance.Chart {
    class M: ObservableObject, Identifiable {
        var id: CPerformance.E
    
        var series: [S]
        
        init(id: CPerformance.E) {
            self.id = id
            self.series = (0 ..< .random(in: 1 ... 4)).compactMap { _ in S() }
        }
    }
    
    class S {        
        let color = NSColor.random
        
        var landmarks: [LM] = []
    }
    
    struct LM {
        var x: Double
        var value: Double
    }
}
