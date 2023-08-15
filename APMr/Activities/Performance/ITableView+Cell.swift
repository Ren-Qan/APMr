//
//  ITableView+Cell.swift
//  APMr
//
//  Created by 任玉乾 on 2023/8/10.
//

import AppKit

extension IPerformanceView.ITableView {
    class Cell: NSView {
        private var notifier: CPerformance.Chart.Notifier? = nil
        private var offsetX: CGFloat = 0
        
        private lazy var contentLayer = Layer()
        
        let label = NSTextField()
        
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
            label.stringValue = "\(offsetX)"
            refresh()
        }
        
        public func scroll(_ offsetX: CGFloat) {
            self.offsetX = offsetX
            label.stringValue = "\(offsetX)"
            refresh()
        }
        
        private func refresh() {
            guard let graph = notifier?.graph else {
                return
            }
            
            contentLayer.clean()
            drawChart(NSEdgeInsets(top: 10, left: 20, bottom: 20, right: 0), graph)
            drawAxis(NSEdgeInsets(top: 10, left: 20, bottom: 20, right: 0), graph)
        }
        
        func drawChart(_ insets: NSEdgeInsets, _ graph: CPerformance.Chart.Notifier.Graph) {
            var frame: CGRect = .zero
            frame.origin = CGPoint(x: insets.left, y: insets.top)
            frame.size.width = contentLayer.bounds.width - insets.left - insets.right
            frame.size.height = contentLayer.bounds.height - insets.top - insets.bottom
            
            let w = graph.axis.width
            let r = graph.axis.count
            var l = Int((-offsetX - insets.left) / graph.axis.width)
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
        
        func drawAxis(_ insets: NSEdgeInsets, _ graph: CPerformance.Chart.Notifier.Graph) {
            var frame: CGRect = .zero
            frame.origin = CGPoint(x: insets.left, y: insets.top)
            frame.size.width = contentLayer.bounds.width - insets.left - insets.right
            frame.size.height = contentLayer.bounds.height - insets.top - insets.bottom
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
