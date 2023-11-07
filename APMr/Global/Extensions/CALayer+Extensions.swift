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
}
