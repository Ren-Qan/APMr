//
//  LineView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import SwiftUI

extension IPerformanceView  {
    struct LineView: NSViewRepresentable {
        @EnvironmentObject var line: CPerformance.Chart.Model.Line
        @EnvironmentObject var axis: CPerformance.Chart.Model.Axis
        
        func makeNSView(context: Context) -> IPerformanceView.NSLineView {
            let view = NSLineView()
            view.target = self
            return view
        }
        
        func updateNSView(_ nsView: IPerformanceView.NSLineView, context: Context) {
            nsView.target = self
            nsView.refresh()
        }
    }
}

extension IPerformanceView {
    class NSLineView: NSView {
        fileprivate var target: LineView? = nil
        
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
            
        }
        
        private func drawLine() {
            content.sublayers?.forEach { layer in
                layer.removeFromSuperlayer()
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
