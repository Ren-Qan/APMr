//
//  CATextLayer+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/8.
//

import AppKit

extension CATextLayer {
    var common: Self {
       return scale(NSScreen.scale)
    }
    
    @discardableResult
    public func font(_ size: CGFloat, _ font: NSFont) -> Self {
        self.fontSize = size
        self.font = font
        return self
    }
    
    @discardableResult
    internal func text(_ text: String) -> Self {
        self.string = text
        return self
    }
    
    @discardableResult
    public func scale(_ value: CGFloat) -> Self {
        self.contentsScale = NSScreen.scale
        return self
    }
    
    @discardableResult
    public func attribute(_ text: NSAttributedString) -> Self {
        self.string = text
        return self
    }
    
    @discardableResult
    public func color(_ color: NSColor) -> Self {
        foregroundColor = color.cgColor
        return self
    }
    
    @discardableResult
    public func iFit() -> Self {
        self.frame.size = preferredFrameSize()
        return self
    }
}
