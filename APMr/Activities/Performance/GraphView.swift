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
        private lazy var axis = Content()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.addSublayer(axis)
            layer?.addSublayer(chart)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            let bounds = self.bounds
            if bounds.size.width != 0, bounds.size.height != 0 {
                target?.notifier.graph.update(bounds.size)
                axis.frame = bounds
                chart.frame = bounds
                refresh()
            }
        }
        
        public func refresh() {
            guard let hint = target?.hint else {
                return
            }
            let config = CPerformance.Chart.Notifier.Graph.Config(offset: hint.offset,
                                                                  edge: NSEdgeInsets(value: 10))
            drawAxis(config)
            drawChart(config)
        }
        
        private func drawAxis(_ config: CPerformance.Chart.Notifier.Graph.Config) {
            guard let graph = target?.notifier.graph else {
                return
            }

            axis.sublayers?.forEach { layer in
                layer.removeFromSuperlayer()
            }
            
            graph.horizontal(config) { [weak self] paint in
                self?.axis.addSublayer(paint.layer)
            }
            
            graph.vertical(config) { [weak self] paint in
                self?.axis.addSublayer(paint.layer)
            }
        }
        
        private func drawChart(_ config: CPerformance.Chart.Notifier.Graph.Config) {
            guard let graph = target?.notifier.graph else {
                return
            }
            
            chart.sublayers?.forEach { layer in
                layer.removeFromSuperlayer()
            }
            
            graph.chart(config) { [weak self] paint in
                self?.chart.addSublayer(paint.layer)
            }
        }
    }
}

extension IPerformanceView {
    fileprivate class Content: CALayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
}
