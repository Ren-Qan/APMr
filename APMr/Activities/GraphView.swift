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
        
        private lazy var content = Content()
        private lazy var axis = Content()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.addSublayer(axis)
            layer?.addSublayer(content)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            if bounds.size.width != 0, bounds.size.height != 0 {
                axis.frame = bounds
                content.frame = bounds
                refresh()
            }
        }
        
        func refresh() {
            drawAxis()
            drawLine()
        }
        
        private func drawAxis() {
            guard let hint = target?.hint,
                  let model = target?.notifier else {
                return
            }
            
            model.graph.xAxis(hint.offset.x, bounds.size)
            model.graph.yAxis()
        }
        
        private func drawLine() {
            guard let hint = target?.hint,
                  let model = target?.notifier else {
                return
            }
            
            model.graph.series.forEach { series in
                let marks = series.landmarks(hint.offset.x, bounds.size)
            }
        }
    }
}

extension IPerformanceView {
    fileprivate class Content: CAShapeLayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
}
