//
//  ITableView+Cell.swift
//  APMr
//
//  Created by 任玉乾 on 2023/8/10.
//

import AppKit
import SwiftUI

extension IPerformanceView.ICharts {
    class Cell: NSView {
        private lazy var checker = Checker()
        private lazy var contentLayer = Content()
        
        private var canVisible: Bool = true
        private var notifier: CPerformance.Chart.Notifier? = nil
        private var hint = IPerformanceView.NSICharts.Hint()
        private var offsetX: CGFloat = 0
        
        private var axisColor: CGColor? = nil
        private var axisTextColor: CGColor? = nil
        private var hintStrokeColor: CGColor? = nil
        private var hintFillColor: CGColor? = nil
                
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.addSublayer(contentLayer)
        }
        
        override func layout() {
            contentLayer.frame = bounds
            contentLayer.backgroundColor = Color.P.BG2.NS.cgColor
            contentLayer.title.foregroundColor = Color.P.H1.NS.cgColor
            contentLayer.title.string = notifier?.type.text
            
            contentLayer.chart.styles = [
                Color.P.BLUE3.NS.cgColor,
                Color.P.GREEN1.NS.cgColor,
                Color.P.PURPLE1.NS.cgColor,
                Color.P.ORANGE1.NS.cgColor,
            ]
            
            contentLayer.axis.lineColor = Color.P.B1.NS.cgColor
            contentLayer.axis.textColor = Color.P.H1.NS.cgColor
            
            contentLayer.hint.strokeColor = Color.P.BLUE1.NS.cgColor
            contentLayer.hint.fillColor = Color.P.BLUE1.NS.withAlphaComponent(0.15).cgColor
            
            contentLayer.chart.sync()
            contentLayer.axis.sync()
            contentLayer.hint.sync()
            
            refresh()
        }
                
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
                
        public func reload(_ notifier: CPerformance.Chart.Notifier,
                           _ hint: IPerformanceView.NSICharts.Hint,
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
        
        public func hint(_ hint: IPerformanceView.NSICharts.Hint) {
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
            
            func config(_ frame: CGRect) -> Layer.Configure {
                return .init(frame, offsetX, hint, graph, checker)
            }
            
            var frame: CGRect = .zero
            frame.origin = CGPoint(x: graph.inset.left, y: graph.inset.bottom)
            frame.size.width = contentLayer.bounds.width - graph.inset.horizontal
            frame.size.height = contentLayer.bounds.height - graph.inset.vertical

            contentLayer.chart.draw(config(frame))
            contentLayer.axis.draw(config(contentLayer.frame))
            contentLayer.hint.draw(config(frame))
        }
    }
}
