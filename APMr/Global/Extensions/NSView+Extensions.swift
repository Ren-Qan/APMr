//
//  NSView+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension NSView {
    @discardableResult internal func add(_ view: NSView) -> Self {
        addSubview(view)
        return self
    }
    
    @discardableResult internal func adds(_ views: [NSView]) -> Self {
        views.forEach { add($0) }
        return self
    }
}
