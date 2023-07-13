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
        
        if notifier.graph.series.count != sources.count {
            notifier.graph.series.removeAll()
            sources.forEach { _ in
                notifier.graph.series.append(.init())
            }
        }
        
        (0 ..< sources.count).forEach { index in
            let source = sources[index]
            let series = notifier.graph.series[index]
            series.width = width
            series.add(source)
        }
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
        let type: DSPMetrics.T
        let graph = Graph()
        
        init(type: DSPMetrics.T) {
            self.type = type
        }
    }
}

// Line
extension CPerformance.Chart.Notifier {
    class Graph {
        fileprivate lazy var axis = Axis()
        fileprivate(set) var series: [Series] = []
        fileprivate(set) var visible: Bool = true
        
        func clean() {
            series.forEach { s in
                axis.clean()
                s.sources.removeAll()
            }
        }
        
        func xAxis(_ offset: CGFloat, _ size: CGSize) -> [Axis.Domain] {
            return []
        }
        
        func yAxis() -> [Axis.Domain] {
            return []
        }
    }
}

extension CPerformance.Chart.Notifier.Graph {
    class Series: Identifiable {
        fileprivate var sources: [DSPMetrics.M.R] = []
        
        fileprivate(set) var visible: Bool = true
        fileprivate(set) var label: String = ""
        fileprivate(set) var style: NSColor = .random
        
        fileprivate(set) var contentSize: CGSize = .zero
        fileprivate(set) var width: CGFloat = 20
                
        func add(_ source: DSPMetrics.M.R) {
            sources.append(source)
            contentSize.width = CGFloat(sources.count) * width
        }
        
        func landmarks(_ offsetX: CGFloat, _ size: CGSize) -> [Landmark] {
            // todo:
            // 1. 根据偏移和页面大小计算出对应的landmark个数
            return []
        }
    }
    
    struct Landmark {
        let x: CGFloat
        let y: CGFloat
    }
}

// Axis
extension CPerformance.Chart.Notifier.Graph {
    struct Axis {
        public let X = Part()
        public let Y = Part()
        
        func clean() {
            X.clean()
            Y.clean()
        }
    }
}

extension CPerformance.Chart.Notifier.Graph.Axis {
    class Part {
        fileprivate(set) var limit = Limit()
        fileprivate(set) var domains = [Domain]()
        
        func clean() {
            limit = Limit()
            domains.removeAll()
        }
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
