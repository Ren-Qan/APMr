//
//  CGRect+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/21.
//

import Foundation

extension CGRect {
    @discardableResult
    public func left(_ inset: CGFloat) -> Self {
        var target = self
        target.origin.x += inset
        target.size.width -= inset
        return target
    }
    
    @discardableResult
    public func right(_ inset: CGFloat) -> Self {
        var target = self
        target.size.width -= inset
        return target
    }
    
    @discardableResult
    public func top(_ inset: CGFloat) -> Self {
        var target = self
        target.size.height -= inset
        return target
    }
    
    @discardableResult
    public func bottom(_ inset: CGFloat) -> Self {
        var target = self
        target.size.height -= inset
        target.origin.y += inset
        return target
    }
    
    @discardableResult
    public func height(_ value: CGFloat) -> Self {
        var target = self
        target.size.height = value
        return target
    }
    
    @discardableResult
    public func width(_ value: CGFloat) -> Self {
        var target = self
        target.size.width = value
        return target
    }
}
