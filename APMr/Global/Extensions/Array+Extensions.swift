//
//  Array+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/17.
//

import AppKit

extension Array {
    @discardableResult
    public func each(_ closure: (_ index: Int, _ element: Element) -> Void) -> Self {
        var i = 0
        forEach { element in
            closure(i, element)
            i += 1
        }
        return self
    }
}

extension ArraySlice {
    @discardableResult
    public func each(_ closure: (_ index: Int, _ element: Element) -> Void) -> Self {
        var i = 0
        forEach { element in
            closure(i, element)
            i += 1
        }
        return self
    }
}
