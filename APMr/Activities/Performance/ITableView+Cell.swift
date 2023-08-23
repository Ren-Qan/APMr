//
//  ITableView+Cell.swift
//  APMr
//
//  Created by 任玉乾 on 2023/8/10.
//

import AppKit

extension IPerformanceView.ITableView {
    class Cell: NSView {
        private lazy var checker = Checker()
        private lazy var contentLayer = Layer()
        
        private var canVisible: Bool = true
        private var notifier: CPerformance.Chart.Notifier? = nil
        private var hint = IPerformanceView.NSITableView.Hint()
        private var offsetX: CGFloat = 0 {
            didSet {
                label.stringValue = "\(offsetX)"
            }
        }
        
        #if DEBUG
        private let label = NSTextField()
        #endif
                
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.backgroundColor = NSColor.random.cgColor
            layer?.addSublayer(contentLayer)
            
            #if DEBUG
            addSubview(label)
            label.isEditable = false
            label.frame = .init(x: 10, y: 0, width: 100, height: 20)
            #endif
        }
        
        override func layout() {
            label.frame.origin.y = bounds.height - 30
            contentLayer.frame = bounds
            refresh()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func reload(_ notifier: CPerformance.Chart.Notifier,
                           _ hint: IPerformanceView.NSITableView.Hint,
                           _ offset: CGFloat) {
            self.notifier = notifier
            self.offsetX = offset
            self.hint = hint
            refresh()
        }
        
        public func scroll(_ offsetX: CGFloat) {
            self.offsetX = offsetX
            refresh()
        }
        
        public func hint(_ hint: IPerformanceView.NSITableView.Hint) {
            self.hint = hint
        }
        
        public func visible(_ visible: Bool) {
            let isNeedRefresh = canVisible != visible
            canVisible = visible
            if isNeedRefresh {
                checker.reset()
                refresh()
            }
        }
        
        private func refresh() {
            guard let graph = notifier?.graph, canVisible else {
                return
            }
            
            drawChart(graph)
            drawAxis(graph)
        }
        
        private func drawChart(_ graph: CPerformance.Chart.Notifier.Graph) {
            var frame: CGRect = .zero
            frame.origin = CGPoint(x: graph.inset.left, y: graph.inset.top)
            frame.size.width = contentLayer.bounds.width - graph.inset.left - graph.inset.right
            frame.size.height = contentLayer.bounds.height - graph.inset.top - graph.inset.bottom
            
            let w = graph.axis.width
            var l = Int((-offsetX - graph.inset.left) / graph.axis.width)
            var r = l + Int(frame.size.width / w) + 2
            if l < 0 { l = 0 }
            if r > graph.axis.count { r = graph.axis.count }
            
            guard l < r else { return }
            guard checker.chart(l, r, offsetX) else { return }
            
            contentLayer.removeChart()
            graph.series.forEach { series in
                contentLayer.addChart(
                    layer { layer, path in
                        let r = min(r, series.sources.count)
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
        
        private func drawAxis(_ graph: CPerformance.Chart.Notifier.Graph) {
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
    fileprivate class Checker {
        private var chart_l: Int = 0
        private var chart_r: Int = 0
        private var chart_offset: CGFloat = 0
        
        private var axis_offset: CGFloat = 0
        private var axis_content_width: CGFloat = 0
        
        private var hint = IPerformanceView.NSITableView.Hint()
        
        func chart(_ l: Int, _ r: Int, _ offset: CGFloat) -> Bool {
            if chart_l == l, chart_r == r, chart_offset == offset {
                return false
            }
            chart_l = l
            chart_r = r
            chart_offset = offset
            return true
        }
        
        func axis(_ contentWidth: CGFloat, _ offset: CGFloat) -> Bool {
            if axis_content_width == contentWidth, axis_offset == offset {
                return false
            }
            axis_content_width = contentWidth
            axis_offset = offset
            return true
        }
        
        func hint(_ hint: IPerformanceView.NSITableView.Hint) -> Bool {
            if self.hint.action == hint.action,
               self.hint.offsetX == hint.offsetX,
               self.hint.area.origin.x == hint.area.origin.x,
               self.hint.area.size.width == hint.area.size.width {
                return false
            }
            self.hint = hint
            return true
        }
        
        func reset() {
            self.axis_offset = 0
            self.axis_content_width = 0
            
            self.chart_offset = 0
            self.chart_r = 0
            self.chart_l = 0
            
            self.hint = .init()
        }
    }

    fileprivate class Layer: CALayer {
        private var chartLayers: [CALayer] = []
        private var axisLayers: [CALayer] = []
        private var hintLayers: [CALayer] = []
        
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
              
        func removeChart() {
            chartLayers.removeAll { layer in
                layer.removeFromSuperlayer()
                return true
            }
        }
        
        func removeAxis() {
            axisLayers.removeAll { layer in
                layer.removeFromSuperlayer()
                return true
            }
        }
        
        func removeHint() {
            chartLayers.removeAll { layer in
                layer.removeFromSuperlayer()
                return true
            }
        }
        
        func addChart(_ layer: CALayer) {
            addSublayer(layer)
            chartLayers.append(layer)
        }
        
        func addAxis(_ layer: CALayer) {
            addSublayer(layer)
            axisLayers.append(layer)
        }
        
        func addHintLayer(_ layer: CALayer) {
            addSublayer(layer)
            hintLayers.append(layer)
        }
    }
}
