//
//  HintView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import SwiftUI

extension IPerformanceView {
    struct HintView: NSViewRepresentable {
        func makeNSView(context: Context) -> IPerformanceView.NSHintView {
            let view = NSHintView()
            view.wantsLayer = true
            view.target = self
            return view
        }
        
        func updateNSView(_ nsView: IPerformanceView.NSHintView, context: Context) {
            nsView.target = self
            nsView.reload()
        }
    }
}

extension IPerformanceView {
    class NSHintView: NSView {
        fileprivate var target: HintView? = nil
        
        private lazy var xAixs: Element = {
            let e = Element()
            layer?.addSublayer(e)
            return e
        }()
        
        private lazy var yAxis: Element = {
            let e = Element()
            layer?.addSublayer(e)
            return e
        }()

        override func layout() {
            if bounds.size.width != 0, bounds.size.height != 0 {
                xAixs.frame = bounds
                yAxis.frame = bounds
                reload()
            }
        }
        
        func reload() {
            yAxis.sublayers?.forEach { layer in
                layer.removeFromSuperlayer()
            }
            
            xAixs.sublayers?.forEach { layer in
                layer.removeFromSuperlayer()
            }
        }
    }
}

extension IPerformanceView {
    fileprivate class Element: CAShapeLayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
    
    fileprivate class Text: CATextLayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
}
