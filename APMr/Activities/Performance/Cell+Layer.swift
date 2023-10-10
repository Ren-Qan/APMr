//
//  Cell+Layer.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/10.
//

import AppKit

extension IPerformanceView.ITableView.Cell {
    class Layer: CALayer {
        fileprivate var styleClosure: (() -> Void)? = nil
        
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
        
        public func draw(_ configure: Configure) {
            
        }
    }
}

extension IPerformanceView.ITableView.Cell.Layer {
    struct Configure {
        let frame: CGRect
        let offset: CGFloat
        let hint: IPerformanceView.NSITableView.Hint
        let graph: CPerformance.Chart.Notifier.Graph
        let checker: IPerformanceView.ITableView.Cell.Checker
        
        init(_ frame: CGRect,
             _ offset: CGFloat,
             _ hint: IPerformanceView.NSITableView.Hint,
             _ graph: CPerformance.Chart.Notifier.Graph,
             _ checker: IPerformanceView.ITableView.Cell.Checker) {
            self.frame = frame
            self.offset = offset
            self.hint = hint
            self.graph = graph
            self.checker = checker
        }
    }
}

extension IPerformanceView.ITableView.Cell.Layer {
    public func clear() {
        sublayers?.forEach { layer in
            layer.removeFromSuperlayer()
        }
    }
    
    public func new(_ frame: CGRect,
                    _ closure: (_ container: IPerformanceView.ITableView.Cell.Layer,
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
    
    public func style(_ closure: @escaping () -> Void) {
        styleClosure = closure
    }
    
    public func sync() {
        styleClosure?()
    }
}
