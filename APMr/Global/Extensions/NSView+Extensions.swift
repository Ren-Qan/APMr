//
//  NSView+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension NSView {
    @discardableResult internal func wants(_ layer: Bool) -> Self {
        wantsLayer = layer
        return self
    }
    
    @discardableResult internal func add(_ view: NSView) -> Self {
        addSubview(view)
        return self
    }
    
    @discardableResult internal func adds(_ views: [NSView]) -> Self {
        views.forEach { add($0) }
        return self
    }
    
    @discardableResult internal func background(_ color: NSColor) -> Self {
        layer?.backgroundColor = color.cgColor
        return self
    }
    
    @discardableResult internal func frame(_ rect: NSRect) -> Self {
        frame = rect
        return self
    }
    
    @discardableResult internal func addTo(_ target: NSView) -> Self {
        target.add(self)
        return self
    }
}
