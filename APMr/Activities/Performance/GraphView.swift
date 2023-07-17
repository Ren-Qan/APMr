//
//  GraphView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import SwiftUI

extension IPerformanceView  {
    struct GraphView: NSViewRepresentable {
        @EnvironmentObject var notifier: CPerformance.Chart.Notifier
        @EnvironmentObject var hint: CPerformance.Hint
        
        func makeNSView(context: Context) -> IPerformanceView.NSGraphView {
            let view = NSGraphView()
            view.target = self
            return view
        }
        
        func updateNSView(_ nsView: IPerformanceView.NSGraphView, context: Context) {
            nsView.target = self
            nsView.refresh()
        }
    }
}

extension IPerformanceView {
    class NSGraphView: NSView {
        fileprivate var target: GraphView? = nil
        
        private lazy var chart = Content()
        private lazy var axis = Axis()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            axis.backgroundColor = NSColor.random.cgColor
            layer?.addSublayer(axis)
            layer?.addSublayer(chart)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            let bounds = self.bounds
            if bounds.size.width != 0, bounds.size.height != 0 {
                axis.frame = bounds
                chart.frame = bounds
                refresh()
            }
        }
        
        public func refresh() {
            guard let hint = target?.hint else {
                return
            }
            
            let edge = NSEdgeInsets(top: 10, left: 10, bottom: 30, right: 10)
            let parameter = CPerformance.Chart.Notifier.Graph.Parameter(offsetX: hint.deltaX,
                                                                        size: bounds.size,
                                                                        edge: edge)
            drawAxis(parameter)
            drawChart(parameter)
        }
        
        private func drawAxis(_ parameter: CPerformance.Chart.Notifier.Graph.Parameter) {
            guard let graph = target?.notifier.graph else {
                return
            }
            
            graph.vertical(parameter) { [weak self] paint in
                self?.axis.setY(paint.layer)
            }
        }
        
        private func drawChart(_ parameter: CPerformance.Chart.Notifier.Graph.Parameter) {
            guard let graph = target?.notifier.graph else {
                return
            }
                        
            graph.chart(parameter) { [weak self] paint in
                self?.chart.set(paint.layer)
            }
        }
    }
}

extension IPerformanceView {
    fileprivate class Content: CALayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
        
        func set(_ layer: CALayer) {
            sublayers?.forEach { layer in
                layer.removeFromSuperlayer()
            }
            addSublayer(layer)
        }
    }
    
    fileprivate class Axis: Content {
        private var y: CALayer? = nil
        private var x: CALayer? = nil
        
        func setX(_ layer: CALayer) {
            x?.removeFromSuperlayer()
            x = nil
            
            addSublayer(layer)
            x = layer
        }
        
        func setY(_ layer: CALayer) {
            y?.removeFromSuperlayer()
            y = nil
            
            addSublayer(layer)
            y = layer
        }
    }
}
