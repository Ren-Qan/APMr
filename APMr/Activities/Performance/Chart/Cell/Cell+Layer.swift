//
//  Cell+Layer.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/10.
//

import AppKit

extension IPerformanceView.ICharts.Cell {
    class Layer: CALayer {
        fileprivate var styleClosure: (() -> Void)? = nil
        
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
        
        public func draw(_ configure: Configure) {
            
        }
    }
    
    class Text: CATextLayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
    
    class ShapeLayer: CAShapeLayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
}

extension IPerformanceView.ICharts.Cell.Layer {
    struct Configure {
        let frame: CGRect
        let actor: CPerformance.Chart.Actor
        let graph: CPerformance.Chart.Drawer.Graph
        let checker: IPerformanceView.ICharts.Cell.Checker
        
        init(_ frame: CGRect,
             _ actor: CPerformance.Chart.Actor,
             _ graph: CPerformance.Chart.Drawer.Graph,
             _ checker: IPerformanceView.ICharts.Cell.Checker) {
            self.frame = frame
            self.actor = actor
            self.graph = graph
            self.checker = checker
        }
    }
}

extension IPerformanceView.ICharts.Cell.Layer {
    public func clear() {
        sublayers?.forEach { layer in
            layer.removeFromSuperlayer()
        }
    }
    
    public func new(_ frame: CGRect,
                    _ closure: (_ container: IPerformanceView.ICharts.Cell.Layer,
                                _ layer: CAShapeLayer,
                                _ path: CGMutablePath) -> Void) {
        let path = CGMutablePath()
        let layer = IPerformanceView.ICharts.Cell.ShapeLayer()
        layer.frame = frame
        layer.lineWidth = 2.5
        layer.fillColor = .clear
        closure(self, layer, path)
        layer.path = path
        addSublayer(layer)
    }
    
    public func style(_ closure: @escaping () -> Void) {
        styleClosure = closure
    }
    
    public func sync() {
        styleClosure?()
    }
}
