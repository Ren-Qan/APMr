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
        
        public func sync(_ model: DSPMetrics.M) {
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
    }
}

extension CPerformance.Chart {
    private func update(_ type: DSPMetrics.T, _ sources: [DSPMetrics.M.R]) {
        guard let notifier = map[type] else {
            return
        }
                
        notifier.graph.set(width, sources)
        notifier.objectWillChange.send()
    }
}

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
        
        fileprivate func clean() {
            x.clean()
            y.clean()
            series.forEach { s in
                s.clean()
            }
        }
        
        fileprivate func set(_ width: CGFloat, _ sources: [DSPMetrics.M.R]) {
            if series.count != sources.count {
                series.removeAll()
                sources.forEach { _ in
                    series.append(.init())
                }
            }
            
            x.update(width)
            (0 ..< sources.count).forEach { i in
                let series = series[i]
                let source = sources[i]
                y.update(source)
                series.update(source)
            }
        }
                
        public func chart(_ parameter: Parameter, _ closure: @escaping (_ paint: Paint) -> Void) {
            let group = DispatchGroup()
            let layer = CALayer()
            layer.frame.size = parameter.size
            
            group.enter()
            DispatchQueue.global().async {
                self.series.forEach { series in
                    if let paint = series.draw(parameter, self.x, self.y) {
                        layer.addSublayer(paint.layer)
                    }
                }
                group.leave()
            }
            
            group.notify(queue: .main) {
                closure(.init(layer: layer))
            }
        }
        
        /// todo: Create Y Axis Path
        public func vertical(_ parameter: Parameter, _ closure: @escaping (_ paint: Paint) -> Void) {

        }
    }
}

extension CPerformance.Chart.Notifier.Graph {
    struct Parameter {
        let deltaX: CGFloat
        let size: CGSize
        let edge: NSEdgeInsets
    }
    
    struct Paint {
        let layer: CALayer
    }
}

extension CPerformance.Chart.Notifier.Graph {
    class Series: Identifiable {
        fileprivate var sources: [DSPMetrics.M.R] = []
        
        private(set) var visible: Bool = true
        private(set) var style: NSColor = .random
        
        private var offsetX: CGFloat = 0
        
        fileprivate func clean() {
            sources.removeAll()
        }
        
        fileprivate func update(_ source: DSPMetrics.M.R) {
            sources.append(source)
        }
        
        fileprivate func draw(_ parameter: Parameter,
                              _ x: X,
                              _ y: Y) -> Paint? {
            let path = CGMutablePath()
            let layer = CAShapeLayer()
            layer.frame.size = parameter.size
            layer.fillColor = .clear
            layer.strokeColor = style.cgColor
            layer.lineCap = .round
            layer.lineWidth = 2
                                    
            offsetX += parameter.deltaX
            
            var rightEdge = parameter.size.width - (x.calculate(sources.count - 1, parameter) + parameter.edge.right)
            if rightEdge >= 0 {
                rightEdge = 0
            }
            
            if offsetX > 0 {
                offsetX = 0
            } else if offsetX <= rightEdge {
                offsetX = rightEdge
            }

            
            var l = Int((-offsetX - parameter.edge.right) / x.width)
            if l < 0 { l = 0 }
            guard l < sources.count else { return nil }
            
            sources[0 ..< sources.count].each { index, element in
                let y = y.calculate(element, parameter)
                let x = x.calculate(index, parameter) + offsetX
                let location = CGPoint(x: x, y: y)
                if index == 0 {
                    path.move(to: location)
                } else {
                    path.addLine(to: location)
                }
                return (x) < parameter.size.width
            }

            layer.path = path
            return Paint(layer: layer)
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
    }
}

extension CPerformance.Chart.Notifier.Graph {
    class X: Axis {
        fileprivate var width: CGFloat = 20
        
        fileprivate func update(_ width: CGFloat) {
            self.width = width
            limit.upper += 1
        }
        
        fileprivate func calculate(_ index: Int, _ parameter: Parameter) -> CGFloat {
            return CGFloat(index) * width + parameter.edge.left
        }
    }
    
    class Y: Axis {
        private var checkTag: CGFloat = 0
        
        fileprivate func update(_ source: DSPMetrics.M.R) {
            limit.upper = max(source.value, limit.upper)
        }
        
        fileprivate func draw(_ parameter: Parameter) -> Paint? {
            let layer = CAShapeLayer()
            layer.frame.size = parameter.size
                        
            return Paint(layer: layer)
        }
        
        fileprivate func calculate(_ source: DSPMetrics.M.R, _ parameter: Parameter) -> CGFloat {
            let h = parameter.size.height - parameter.edge.bottom - parameter.edge.top
            return h * source.value / limit.upper + parameter.edge.bottom
        }
    }
}


#if DEBUG
extension CPerformance.Chart {
    static var debug_Data = DSPMetrics.M()
    public func addRandom(_ count: Int) {
        (0 ..< count).forEach { _ in
            CPerformance.Chart.debug_Data.cpu.total.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.cpu.process.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.gpu.device.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.gpu.renderer.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.gpu.tiler.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.fps.fps.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.io.read.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.io.write.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.io.readDelta.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.io.writeDelta.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.network.up.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.network.down.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.network.upDelta.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.network.downDelta.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.memory.memory.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.memory.resident.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.memory.vm.value = .random(in:  0.1 ... 99.9)

            CPerformance.Chart.debug_Data.diagnostic.amperage.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.diagnostic.battery.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.diagnostic.temperature.value = .random(in:  0.1 ... 99.9)
            CPerformance.Chart.debug_Data.diagnostic.voltage.value = .random(in:  0.1 ... 99.9)
            
            sync(CPerformance.Chart.debug_Data)
        }
    }
}
#endif
