//
//  ITableView+Cell.swift
//  APMr
//
//  Created by 任玉乾 on 2023/8/10.
//

import AppKit
import SwiftUI

extension IPerformanceView.ITableView {
    class Cell: NSView {
        private lazy var checker = Checker()
        private lazy var contentLayer = Content()
        
        private var canVisible: Bool = true
        private var notifier: CPerformance.Chart.Notifier? = nil
        private var hint = IPerformanceView.NSITableView.Hint()
        private var offsetX: CGFloat = 0 {
            didSet {
            #if DEBUG
                label.stringValue = "\(offsetX)"
            #endif
            }
        }
        
        #if DEBUG
        private let label = NSTextField()
        #endif
        
        private var axisColor: CGColor? = nil
        private var axisTextColor: CGColor? = nil
        private var hintStrokeColor: CGColor? = nil
        private var hintFillColor: CGColor? = nil
                
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.addSublayer(contentLayer)
            
            #if DEBUG
            addSubview(label)
            label.isEditable = false
            label.frame = .init(x: 50, y: 0, width: 100, height: 20)
            #endif
        }
        
        override func layout() {
            label.frame.origin.y = bounds.height - 30
            contentLayer.frame = bounds

            contentLayer.backgroundColor = Color.P.BG2.NS.cgColor
            
            axisColor = Color.P.B1.NS.cgColor
            axisTextColor = Color.P.H1.NS.cgColor
            hintStrokeColor = Color.P.BLUE1.NS.cgColor
            hintFillColor = Color.P.BLUE1.NS.withAlphaComponent(0.15).cgColor
            
            contentLayer.chart.sync()
            contentLayer.axis.sync()
            contentLayer.hint.sync()
            
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
            refresh()
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
            
            var frame: CGRect = .zero
            frame.origin = CGPoint(x: graph.inset.left, y: graph.inset.bottom)
            frame.size.width = contentLayer.bounds.width - graph.inset.horizontal
            frame.size.height = contentLayer.bounds.height - graph.inset.vertical
            
            drawChart(graph, frame)
            drawAxis(graph, contentLayer.frame)
            drawHint(graph, frame)
        }
    }
}

extension IPerformanceView.ITableView.Cell {
    fileprivate func drawChart(_ graph: CPerformance.Chart.Notifier.Graph,
                               _ frame: CGRect) {
        let w = graph.axis.width
        var l = Int((-offsetX) / graph.axis.width)
        var r = l + Int(frame.size.width / w) + 4
        if l < 0 { l = 0 }
        if r > graph.axis.count { r = graph.axis.count }
        
        guard l < r else { return }
        guard checker.chart(l, r, offsetX) else { return }
        
        contentLayer.chart.clear()
        graph.series.forEach { series in
            contentLayer.chart.new(frame) { container, layer, path in
                let r = min(r, series.sources.count)
                layer.masksToBounds = true
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
                    
                    return x < frame.width + graph.inset.horizontal
                }
                
                container.style {
                    layer.strokeColor = series.style.cgColor
                }
            }
        }
    }
    
    fileprivate func drawAxis(_ graph: CPerformance.Chart.Notifier.Graph,
                              _ frame: CGRect) {
        let count = Int(frame.width / graph.axis.width) + 2
        let upper = graph.axis.upper?.value ?? 0
        guard checker.axis(frame.width, offsetX, count, upper) else { return }
        var l = Int((-offsetX) / graph.axis.width)
        if l < 0 { l = 0 }
        let w = graph.axis.width
        
        contentLayer.axis.clear()
        contentLayer.axis.new(frame) { container, layer, path in
            let LW: CGFloat = 1.5
            layer.masksToBounds = true
            layer.lineWidth = LW

            // Y
            let x = graph.inset.left
            path.move(to: .init(x: x, y: graph.inset.bottom))
            path.addLine(to: .init(x: x, y: frame.height - graph.inset.top))
            path.addLine(to: .init(x: x - 5, y: frame.height - graph.inset.top))

            // X
            var texts: [CATextLayer] = []
            (0 ..< count).each { _, padding in
                let index = l + padding
                var x = CGFloat(index) * w + graph.inset.left + offsetX
                if x < graph.inset.left { x = graph.inset.left }
                let point = CGPoint(x: x, y: graph.inset.bottom)
                if padding == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
                guard (index + 1) % 5 == 0 || padding == 0 else { return x < frame.width + graph.inset.horizontal }
                path.addLine(to: .init(x: x, y: graph.inset.bottom - 6))
                path.move(to: point)
                
                let text = CATextLayer()
                text.fontSize = 10
                text.alignmentMode = .center
                
                text.string = "\(index + 1) s"
                text.frame = .init(x: x - 25, y: graph.inset.bottom - 16, width: 50, height: 10)
                layer.addSublayer(text)
                
                texts.append(text)
                return x < frame.width + graph.inset.horizontal
            }
            
            // Style
            container.style { [weak self] in
                layer.strokeColor = self?.axisColor
                texts.forEach { text in
                    text.foregroundColor = self?.axisTextColor
                }
            }
            container.sync()
        }
    }
    
    fileprivate func drawHint(_ graph: CPerformance.Chart.Notifier.Graph,
                              _ frame: CGRect) {
        guard checker.hint(hint, offsetX, frame.size.width) else { return }
        
        contentLayer.hint.clear()
        if hint.action == .none { return }
        
        contentLayer.hint.new(frame) { container, layer, path in
            let x = hint.area.origin.x - frame.origin.x - hint.offsetX + offsetX
            layer.lineWidth = 1.5
            layer.lineDashPattern = [5, 1.5]
            layer.masksToBounds = true
            
            if hint.action == .click {
                path.move(to: .init(x: x, y: 0))
                path.addLine(to: .init(x: x, y: frame.height))
            } else if hint.action == .drag {
                let w = hint.area.size.width
                path.addRect(.init(x: x, y: 0, width: w, height: frame.height))
                layer.fillColor = Color.P.BLUE1.NS.withAlphaComponent(0.15).cgColor
            }
            
            let isDrag = hint.action == .drag
            container.style { [weak self] in
                layer.strokeColor = self?.hintStrokeColor
                if isDrag {
                    layer.fillColor = self?.hintFillColor
                }
            }
            container.sync()
        }
    }
}

extension IPerformanceView.ITableView.Cell {
    fileprivate class Checker {
        private var chart_l: Int = 0
        private var chart_r: Int = 0
        private var chart_offset: CGFloat = 0
        
        private var axis_offset: CGFloat = 0
        private var axis_content_width: CGFloat = 0
        private var axis_count: Int = 0
        private var axis_upper: CGFloat = 0
        
        private var hint = IPerformanceView.NSITableView.Hint()
        private var hint_offsetX: CGFloat = 0
        private var hint_contentW: CGFloat = 0
        
        func chart(_ l: Int, _ r: Int, _ offset: CGFloat) -> Bool {
            if chart_l == l,
               chart_r == r,
               chart_offset == offset {
                return false
            }
            chart_l = l
            chart_r = r
            chart_offset = offset
            return true
        }
        
        func axis(_ contentWidth: CGFloat,
                  _ offset: CGFloat,
                  _ count: Int,
                  _ upper: CGFloat) -> Bool {
            if axis_content_width == contentWidth,
               axis_offset == offset,
               axis_count == count,
               axis_upper == upper{
                return false
            }
            axis_content_width = contentWidth
            axis_offset = offset
            axis_count = count
            axis_upper = upper
            return true
        }
        
        func hint(_ hint: IPerformanceView.NSITableView.Hint,
                  _ offset: CGFloat,
                  _ contentW: CGFloat) -> Bool {
            if self.hint.action == hint.action,
               self.hint.offsetX == hint.offsetX,
               self.hint.area.origin.x == hint.area.origin.x,
               self.hint.area.size.width == hint.area.size.width,
               self.hint_offsetX == offset,
               self.hint_contentW == contentW{
                return false
            }
            self.hint = hint
            self.hint_offsetX = offset
            self.hint_contentW = contentW
            return true
        }
        
        func reset() {
            self.axis_offset = 0
            self.axis_content_width = 0
            self.axis_upper = 0
            self.axis_count = 0
            
            self.chart_offset = 0
            self.chart_r = 0
            self.chart_l = 0
            
            self.hint = .init()
            self.hint_offsetX = 0
        }
    }

    fileprivate class Content: Layer {
        fileprivate var chart = Layer()
        fileprivate var axis = Layer()
        fileprivate var hint = Layer()
                
        override init() {
            super.init()
            addSublayer(chart)
            addSublayer(axis)
            addSublayer(hint)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
                
        override func layoutSublayers() {
            chart.frame = bounds
            axis.frame = bounds
            hint.frame = bounds
        }
    }
    
    fileprivate class Layer: CALayer {
        private var styleClosure: (() -> Void)? = nil
        
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
        
        func clear() {
            sublayers?.forEach { layer in
                layer.removeFromSuperlayer()
            }
        }
                
        func new(_ frame: CGRect, _ closure: (_ container: Layer,
                                              _ layer: CAShapeLayer,
                                              _ path: CGMutablePath) -> Void) {
            let path = CGMutablePath()
            let layer = CAShapeLayer()
            layer.frame = frame
            layer.lineWidth = 2.5
            layer.fillColor = .clear
            closure(self, layer, path)
            layer.path = path
            addSublayer(layer)
        }
        
        func style(_ closure: @escaping () -> Void) {
            styleClosure = closure
        }
        
        func sync() {
            styleClosure?()
        }
    }
}
