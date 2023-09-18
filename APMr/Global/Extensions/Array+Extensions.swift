//
//  Array+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/17.
//

import AppKit

extension Sequence {
    @discardableResult
    public func each(_ closure: (_ index: Int, _ element: Element) -> Bool) -> Self {
        for (index, item) in enumerated() {
            guard closure(index, item) else {
                return self
            }
        }
        return self
    }
}
