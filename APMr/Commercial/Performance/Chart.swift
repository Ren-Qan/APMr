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
        private(set) var notifiers: [Notifier] = []
        
        private var map: [DSPMetrics.T : Notifier] = [:]
        private var width: CGFloat = 20
        
        public func sync(_ model: DSPMetrics.M) {
            snap(model)
        }
        
        public func preset(_ model: DSPMetrics.M) {
            model.all.forEach { i in
                if self.map[i.type] == nil {
                    let notifier = Notifier(type: i.type)
                    self.notifiers.append(notifier)
                    self.map[i.type] = notifier
                }
            }
        }
        
        public func clean() {
            notifiers.forEach { notifier in
                notifier.graph.clean()
            }
        }
    }
}

extension CPerformance.Chart {
    private func snap(_ model: DSPMetrics.M) {
        let cpu =           [model.cpu.total, model.cpu.process]
        let gpu =           [model.gpu.device, model.gpu.tiler, model.gpu.renderer]
        let fps =           [model.fps.fps]
        let memory =        [model.memory.memory, model.memory.resident, model.memory.vm]
        let io =            [model.io.write, model.io.readDelta, model.io.writeDelta, model.io.readDelta]
        let network =       [model.network.down, model.network.up, model.network.downDelta, model.network.upDelta]
        let diagnostic =    [model.diagnostic.amperage, model.diagnostic.battery, model.diagnostic.temperature, model.diagnostic.voltage]
        
        update(.CPU, cpu)
        update(.GPU, gpu)
        update(.FPS, fps)
        update(.Memory, memory)
        update(.IO, io)
        update(.Network, network)
        update(.Diagnostic, diagnostic)
    }
        
    private func update(_ type: DSPMetrics.T, _ sources: [DSPMetrics.M.R]) {
        guard let notifier = map[type] else {
            return
        }
                
        notifier.graph.set(width, sources)
        notifier.objectWillChange.send()
    }
}

#if DEBUG
extension CPerformance.Chart {
    public func addRandom(_ count: Int) {
        
    }
}
#endif

extension CPerformance.Chart {
    class Notifier: Identifiable, ObservableObject {
        public let type: DSPMetrics.T
        public let graph = Graph()
        
        init(type: DSPMetrics.T) {
            self.type = type
        }
    }
}

// Line
extension CPerformance.Chart.Notifier {
    class Graph {
        private lazy var x = X()
        private lazy var y = Y()
        
        private var series: [Series] = []
        private var visible: Bool = true
        
        private var windowSize: CGSize = .zero
        private var contentSize: CGSize = .zero

        fileprivate func clean() {
            x.clean()
            y.clean()
            series.forEach { s in
                s.sources.removeAll()
            }
        }
        
        fileprivate func set(_ width: CGFloat, _ sources: [DSPMetrics.M.R]) {
            var count = 0
            
            if series.count != sources.count {
                series.removeAll()
                sources.forEach { _ in
                    series.append(.init())
                }
            }
            
            x.add()
            (0 ..< sources.count).forEach { i in
                let series = series[i]
                let source = sources[i]
                
                series.update(width, source)
                count = max(count, series.sources.count)
                y.update(source)
            }
            
            contentSize.width = CGFloat(count) * width
        }
        
        /// todo: check
        private func check(_ config: Config) -> Bool {
            return false
        }
        
        public func update(_ windowSize: CGSize) {
            self.windowSize = windowSize
            self.contentSize.height = windowSize.height
        }
        
        /// todo: Create X Axis Path
        public func horizontal(_ config: Config, _ closure: @escaping (_ paint: Paint) -> Void) {
            if check(config) {
                DispatchQueue.global().async {
                    if let paint = self.x.draw(config, self.windowSize) {
                        DispatchQueue.main.async {
                            closure(paint)
                        }
                    }
                }
            } else {
                if let paint = x.paint {
                    closure(paint)
                }
            }
        }
        
        /// todo: Create Y Axis Path
        public func vertical(_ config: Config, _ closure: @escaping (_ paint: Paint) -> Void) {
            if check(config) {
                DispatchQueue.global().async {
                    if let paint = self.y.draw(config, self.windowSize) {
                        DispatchQueue.main.async {
                            closure(paint)
                        }
                    }
                }
            } else {
                if let paint = y.paint {
                    closure(paint)
                }
            }
        }
        
        /// todo: Create series Line Paths
        public func chart(_ config: Config, _ closure: @escaping (_ paint: Paint) -> Void) {
            if check(config) {
                DispatchQueue.global().async {
                    self.series.forEach { series in
                        if let paint = series.draw(config, self.windowSize) {
                            DispatchQueue.main.async {
                                closure(paint)
                            }
                        }
                    }
                }
            } else {
                series.forEach { series in
                    if let paint = series.paint {
                        closure(paint)
                    }
                }
            }
        }
    }
}

extension CPerformance.Chart.Notifier.Graph {
    struct Config {
        let offset: CGPoint
        let edge: NSEdgeInsets
    }
    
    struct Paint {
        let layer: CALayer
    }
}

extension CPerformance.Chart.Notifier.Graph {
    class Series: Identifiable {
        fileprivate var sources: [DSPMetrics.M.R] = []
        fileprivate var paint: Paint? = nil
        
        private(set) var visible: Bool = true
        private(set) var label: String = ""
        private(set) var style: NSColor = .random
        private(set) var width: CGFloat = 20

        fileprivate func update(_ width: CGFloat, _ source: DSPMetrics.M.R) {
            self.width = width
            sources.append(source)
        }
        
        fileprivate func draw(_ config: Config, _ windowSize: CGSize) -> Paint? {
            
            return nil
        }
        
        struct Landmark {
            let x: CGFloat
            let y: CGFloat
        }
    }
}

// Axis
extension CPerformance.Chart.Notifier.Graph {
    class Axis {
        fileprivate(set) var limit = Limit()
        fileprivate var paint: Paint? = nil
        
        fileprivate func clean() {
            limit = Limit()
        }
        
        struct Limit {
            var upper: CGFloat = 0
            var lower: CGFloat = 0
        }
        
        struct Domain {
            let label: String
            let x: CGFloat
            let y: CGFloat
        }
    }
}

extension CPerformance.Chart.Notifier.Graph {
    class X: Axis {
        fileprivate func add() {
            limit.upper += 1
        }
        
        fileprivate func draw(_ config: Config, _ windowSize: CGSize) -> Paint? {
            return nil
        }
    }
    
    class Y: Axis {
        fileprivate func update(_ source: DSPMetrics.M.R) {
            limit.upper = max(source.value, limit.upper)
        }
        
        fileprivate func draw(_ config: Config, _ windowSize: CGSize) -> Paint? {
            return nil
        }
    }
}
