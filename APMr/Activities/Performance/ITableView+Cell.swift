//
//  ITableView+Cell.swift
//  APMr
//
//  Created by 任玉乾 on 2023/8/10.
//

import AppKit

extension IPerformanceView.ITableView {
    class Cell: NSView {
        private lazy var contentLayer = Layer()
        private var notifier: CPerformance.Chart.Notifier? = nil
        private var offsetX: CGFloat = 0 {
            didSet {
                label.stringValue = "\(offsetX)"
            }
        }
        
        private let label = NSTextField()
        
        public var canVisible: Bool = true
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.backgroundColor = NSColor.random.cgColor
            layer?.addSublayer(contentLayer)
            
            addSubview(label)
            label.isEditable = false
            label.frame = .init(x: 10, y: 0, width: 100, height: 20)
        }
        
        override func layout() {
            label.frame.origin.y = bounds.height - 30
            contentLayer.frame = bounds
            refresh()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func reload(_ notifier: CPerformance.Chart.Notifier, _ offsetX: CGFloat) {
            self.notifier = notifier
            self.offsetX = offsetX
            refresh()
        }
        
        public func scroll(_ offsetX: CGFloat) {
            self.offsetX = offsetX
            refresh()
        }
        
        private func refresh() {
            guard let graph = notifier?.graph, canVisible else {
                return
            }
            
            contentLayer.clean()
            drawChart(graph)
            drawAxis(graph)
        }
        
        func drawChart(_ graph: CPerformance.Chart.Notifier.Graph) {
            var frame: CGRect = .zero
            frame.origin = CGPoint(x: graph.inset.left, y: graph.inset.top)
            frame.size.width = contentLayer.bounds.width - graph.inset.left - graph.inset.right
            frame.size.height = contentLayer.bounds.height - graph.inset.top - graph.inset.bottom
            
            let w = graph.axis.width
            let r = graph.axis.count
            var l = Int((-offsetX - graph.inset.left) / graph.axis.width)
            if l < 0 { l = 0 }
            
            guard l < r else { return }
            
            graph.series.forEach { series in
                contentLayer.addSublayer(
                    layer { layer, path in
                        layer.frame = frame
                        layer.strokeColor = series.style.cgColor
                        series.sources[l ..< r].each { index, element in
                            let x: CGFloat = CGFloat(index + l) * w + offsetX
                            let y: CGFloat = element.value / (graph.axis.upper?.value ?? 1) * frame.height
                            let point = CGPoint(x: x, y: y)
                            
                            if index == 0 {
                                path.move(to: point)
                            } else {
                                path.addLine(to: point)
                            }
                            
                            return x < frame.maxX
                        }
                    }
                )
            }
        }
        
        func drawAxis(_ graph: CPerformance.Chart.Notifier.Graph) {
            var frame: CGRect = .zero
            frame.origin = CGPoint(x: graph.inset.left, y: graph.inset.top)
            frame.size.width = contentLayer.bounds.width - graph.inset.left - graph.inset.right
            frame.size.height = contentLayer.bounds.height - graph.inset.top - graph.inset.bottom
        }
    }
}

extension IPerformanceView.ITableView.Cell {
    fileprivate func layer(_ closure: (_ layer: CAShapeLayer, _ path: CGMutablePath) -> Void) -> CALayer {
        let path = CGMutablePath()
        let layer = CAShapeLayer()
        layer.lineWidth = 3
        layer.fillColor = .clear
        closure(layer, path)
        layer.path = path
        return layer
    }
}

extension IPerformanceView.ITableView.Cell {
    fileprivate class Layer: CALayer {
        
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
        
        func clean() {
            sublayers?.forEach { layer in
                layer.removeFromSuperlayer()
            }
            sublayers?.removeAll()
        }
    }
}
