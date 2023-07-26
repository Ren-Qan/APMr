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
        private lazy var hint = HintRender()
        
        private var series: [Series] = []
        private var visible: Bool = true
        
        private var scrollEdge = Edge()
    
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
        
        private func offset(_ parameter: Parameter) -> CGFloat {
            let allCount = Int(parameter.size.width / x.width)
            let dataCount = Int(x.limit.upper)
            
            var offsetX: CGFloat = 0
            
            if dataCount > allCount {
                let lastX = x.calculate(dataCount - 1, parameter)
                let low = parameter.size.width - lastX - parameter.edge.right
                
                if scrollEdge.state == .latest {
                    offsetX = low
                } else {
                    offsetX = scrollEdge.lastOffset
                }
                
                if parameter.deltaX != 0 {
                    if scrollEdge.state == .latest {
                        scrollEdge.state = .stable
                    }
                    
                    offsetX += parameter.deltaX
                }
            
                if offsetX > 0 {
                    offsetX = 0
                }
                
                if offsetX < low {
                    scrollEdge.state = .latest
                    offsetX = low
                }
            }
            
            scrollEdge.lastOffset = offsetX
            return offsetX
        }
        
        public func chart(_ parameter: Parameter,
                          _ closure: @escaping (_ paint: Paint) -> Void) {
            let layer = CALayer()
            let offset = self.offset(parameter)
            
            layer.frame.size = parameter.size
                
            DispatchQueue.global().async {
                var padding = Int(-offset / self.x.width) - 1
                if padding < 0 { padding = 0 }
                
                self.series.forEach { series in
                    if let paint = series.draw(parameter, offset, padding, self.x, self.y) {
                        layer.addSublayer(paint)
                    }
                }
                
                if let paint = self.x.draw(parameter, offset, padding) {
                    layer.addSublayer(paint)
                }
                
                if let paint = self.y.draw(parameter) {
                    layer.addSublayer(paint)
                }
                
                if let paint = self.hint.draw(parameter, offset) {
                    layer.addSublayer(paint)
                }
                
                DispatchQueue.main.async {
                    closure(.init(layer: layer))
                }
            }
        }
    }
}

extension CPerformance.Chart.Notifier.Graph {
    struct Parameter {
        let deltaX: CGFloat
        let size: CGSize
        let edge: NSEdgeInsets
        let active: CPerformance.Hint.Active?
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
        
        fileprivate func clean() {
            sources.removeAll()
        }
        
        fileprivate func update(_ source: DSPMetrics.M.R) {
            sources.append(source)
        }
        
        fileprivate func draw(_ parameter: Parameter,
                              _ offsetX: CGFloat,
                              _ padding: Int,
                              _ x: X,
                              _ y: Y) -> CALayer? {
            let sources = sources
            guard sources.count > 0 else {
                return nil
            }
            
            let layerX = parameter.edge.left
            
            var size = parameter.size
            size.width -= layerX
            
            var edge = parameter.edge
            edge.left = 0
            
            let parameter = Parameter(deltaX: parameter.deltaX,
                                      size: size,
                                      edge: edge,
                                      active: parameter.active)
            
            let path = CGMutablePath()
            let layer = CAShapeLayer()
            layer.frame.origin.x = layerX
            layer.frame.size = parameter.size
            layer.fillColor = .clear
            layer.strokeColor = style.cgColor
            layer.lineCap = .round
            layer.lineWidth = 2
            layer.masksToBounds = true
            
            sources[padding ..< sources.count].each { index, element in
                let y = y.calculate(element, parameter)
                let x = x.calculate((index + padding), parameter) + offsetX
                let location = CGPoint(x: x, y: y)
                if index == 0 {
                    path.move(to: location)
                } else {
                    path.addLine(to: location)
                }
                return x < parameter.size.width
            }

            layer.path = path
            
            return layer
        }
    }
}

extension CPerformance.Chart.Notifier.Graph {
    fileprivate struct Edge {
        enum S {
            case stable
            case latest
        }
        
        var state: S = .latest
        var lastOffset: CGFloat = 0
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
    
    class X: Axis {
        fileprivate var width: CGFloat = 20
        fileprivate var offset: CGFloat = 0
        
        fileprivate var style: NSColor = .black.withAlphaComponent(0.3)
        
        fileprivate func update(_ width: CGFloat) {
            self.width = width
            limit.upper += 1
        }
        
        fileprivate func calculate(_ index: Int, _ parameter: Parameter) -> CGFloat {
            return CGFloat(index) * width + parameter.edge.left
        }
        
        fileprivate func draw(_ parameter: Parameter,
                              _ offset: CGFloat,
                              _ padding: Int) -> CALayer? {
            let path = CGMutablePath()
            let layer = CAShapeLayer()
            layer.frame.size = parameter.size
            layer.fillColor = .clear
            layer.strokeColor = style.cgColor
            layer.lineCap = .round
            layer.lineWidth = 1
            
            var padding = padding
            var x = CGFloat(padding) * width + parameter.edge.left + offset
        
            let y = parameter.edge.bottom - 1
            
            path.move(to: CGPoint(x: parameter.edge.left, y: y))
            path.addLine(to: CGPoint(x: parameter.size.width, y: y))
            
            while(x < parameter.size.width) {
                if padding % 5 == 0, x >= parameter.edge.left {
                    path.move(to: CGPoint(x: x - 0.5, y: y))
                    path.addLine(to: CGPoint(x: x - 0.5, y: y - 10))
                }
                
                x = CGFloat(padding) * width + parameter.edge.left + offset
                padding += 1
            }
            
            layer.path = path
            
            return layer
        }
    }
    
    class Y: Axis {
        private var checkTag: CGFloat = 0
        fileprivate var style: NSColor = .black.withAlphaComponent(0.3)
        
        fileprivate func update(_ source: DSPMetrics.M.R) {
            limit.upper = max(source.value, limit.upper)
        }
        
        fileprivate func calculate(_ source: DSPMetrics.M.R, _ parameter: Parameter) -> CGFloat {
            let h = parameter.size.height - parameter.edge.bottom - parameter.edge.top
            return h * source.value / limit.upper + parameter.edge.bottom
        }
        
        fileprivate func draw(_ parameter: Parameter) -> CALayer? {
            let path = CGMutablePath()
            let layer = CAShapeLayer()
            layer.frame.size = parameter.size
            layer.fillColor = .clear
            layer.strokeColor = style.cgColor
            layer.lineCap = .round
            layer.lineWidth = 1
            
            let tags = 5
            let x = parameter.edge.right - 1
            let h = parameter.size.height - parameter.edge.top
            let bottom = parameter.edge.bottom - 1
            
            path.move(to: CGPoint(x: x, y: bottom))
            path.addLine(to: CGPoint(x: parameter.edge.left, y: h))
        
            let padding = (h - bottom) / CGFloat(tags)
            (1 ... tags).forEach { i in
                let y = bottom + CGFloat(i) * padding
                path.move(to: CGPoint(x: x, y: y))
                path.addLine(to: CGPoint(x: x - 3, y: y))
            }
            
            layer.path = path
            
            return layer
        }
    }
}

extension CPerformance.Chart.Notifier.Graph {
    fileprivate class HintRender {
        private let style = NSColor.random
        private var offsetX: CGFloat = 0
        
        private var isNeedClickToHide = false
        fileprivate var isInShow = false
        
        fileprivate class Content: CAShapeLayer {
            override func action(forKey event: String) -> CAAction? {
                return nil
            }
        }
        
        private lazy var layer: Content = {
            let layer = Content()
            layer.fillColor = .clear
            layer.strokeColor = style.cgColor
            layer.lineCap = .round
            layer.lineWidth = 1
            layer.masksToBounds = true
            return layer
        }()
        
        func draw(_ parameter: Parameter, _ offset: CGFloat) -> CALayer? {
            guard let active = parameter.active else {
                return nil
            }
            
            layer.frame.size.height = parameter.size.height
            layer.frame.size.width = parameter.size.width - parameter.edge.left
            layer.frame.origin.x = parameter.edge.left

            switch active.state {
                case .began:
                    if isInShow {
                        isNeedClickToHide = true
                    }
                    offsetX = offset
                    return nil
                    
                case .changed, .ended:
                    if isNeedClickToHide, active.type == .click {
                        isNeedClickToHide = false
                        isInShow = false
                        layer.path = nil
                        return nil
                    }
                    let path = CGMutablePath()
                    
                    if active.type == .click {
                        let x = active.value.origin.x + offset - offsetX - parameter.edge.left
                        path.move(to: CGPoint(x: x, y: parameter.edge.bottom))
                        path.addLine(to:  CGPoint(x: x, y: parameter.size.height - parameter.edge.top))
                                            
                        layer.fillColor = .clear
                    } else {
                        var r = active.value
                        r.origin.x += offset - offsetX - parameter.edge.left
                        r.origin.y = parameter.edge.bottom
                        r.size.height = parameter.size.height - parameter.edge.bottom - parameter.edge.top
                        path.addRect(r)
                                            
                        layer.fillColor = style.withAlphaComponent(0.1).cgColor
                    }
                        
                    layer.path = path
                default: return nil
            }
                      
            isInShow = true
            return layer
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
