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
            label.stringValue = "\(offsetX)"
            refresh()
        }
        
        public func scroll(_ offsetX: CGFloat) {
            label.stringValue = "\(offsetX)"
            refresh()
        }
        
        private func refresh() {
            guard let graph = notifier?.graph else {
                return
            }
            
            contentLayer.clean()
            
            let B = (graph.axis.upper?.value ?? 1) * 1.25
            
            let VP = 20.0
            let CH = bounds.height - VP * 2
            
            graph.series.forEach { series in
                let path = CGMutablePath()
                let layer = CAShapeLayer()
                layer.fillColor = .clear
                layer.strokeColor = series.style.cgColor
                layer.lineWidth = 3
                
                series.sources.each { index, element in
                    let x: CGFloat = 10 + CGFloat(index) * 20
                    let y: CGFloat = (element.value / B) * CH + VP
                    let point = CGPoint(x: x, y: y)
                    
                    if index == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                    
                    return true
                }
                
                layer.path = path
                contentLayer.addSublayer(layer)
            }
        }
        
        
    }
}

extension IPerformanceView.ITableView.Cell {
    fileprivate class Layer: CALayer {
        func clean() {
            sublayers?.forEach { layer in
                layer.removeFromSuperlayer()
            }
            sublayers?.removeAll()
        }
    }
}
