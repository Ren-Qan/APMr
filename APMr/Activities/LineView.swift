//
//  LineView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import SwiftUI

extension IPerformanceView  {
    struct LineView: NSViewRepresentable {        
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
            content.sublayers?.forEach { layer in
                layer.removeFromSuperlayer()
            }

//            target?.model.series.forEach { series in
//                let modelLayer = CAShapeLayer()
//                modelLayer.strokeColor = series.color.cgColor
//                modelLayer.fillColor = .clear
//                modelLayer.lineWidth = 3
//                modelLayer.lineCap = .round
//                modelLayer.lineJoin = .bevel
//
//                let path = CGMutablePath()
//                let h = self.frame.height
//
//                var isFirst = true
//
//                series.landmarks.forEach { landmark in
//                    let point: CGPoint = .init(x: landmark.x * 80 + 10, y: ((landmark.value + 30) / 150.0) * h)
//                    if isFirst {
//                        isFirst = false
//                        path.move(to: point)
//                    } else {
//                        path.addLine(to: point)
//                    }
//                }
//
//                modelLayer.path = path
//                self.content.addSublayer(modelLayer)
//            }
        }
        
        private func drawAxis() {
            
        }
        
        private func drawLine() {
            
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
