//
//  CALayer+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/7.
//

import AppKit

extension CALayer {
    @discardableResult
    public func add(_ layer: CALayer) -> Self {
        addSublayer(layer)
        return self
    }
    
    @discardableResult
    public func adds(_ layers: [CALayer]) -> Self {
        layers.forEach { layer in
            add(layer)
        }
        return self
    }
    
    @discardableResult
    public func clean() -> Self {
        sublayers?.removeAll { layer in
            layer.removeFromSuperlayer()
            return true
        }
        return self
    }
    
    @discardableResult
    public func background(_ color: NSColor) -> Self {
        backgroundColor = color.cgColor
        return self
    }
    
    @discardableResult
    public func anchor(_ anchor: CGPoint) -> Self {
        var newPoint = CGPoint(x: self.bounds.size.width * anchor.x,
                               y: self.bounds.size.height * anchor.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x,
                               y: self.bounds.size.height * anchorPoint.y)
        
        newPoint = newPoint.applying(affineTransform())
        oldPoint = oldPoint.applying(affineTransform())
        
        var position = position
        
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        self.position = position
        self.anchorPoint = anchor
        
        return self
    }
    
    @discardableResult
    public func rotate(_ degress: CGFloat) -> Self {
        transform = CATransform3DMakeRotation((degress / 180) * .pi, 0, 0, 1)
        return self
    }
    
    @discardableResult
    public func alpha(_ value: CGFloat) -> Self {
        opacity = Float(value)
        return self
    }
    
    @discardableResult
    public func then(_ closure: (_ entity: Self) -> Void) -> Self {
        closure(self)
        return self
    }
    
    @discardableResult
    public func addTo(_ target: CALayer) -> Self {
        target.add(self)
        return self
    }
}
