//
//  NSImageView+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/7.
//

import AppKit

extension NSImageView {
    enum ContentMode {
        case fit
        case fill
    }
    @discardableResult
    internal func mode(_ value: ContentMode) -> Self {
        switch value {
            case .fit:
                self.imageScaling = .scaleProportionallyUpOrDown
            case .fill:
                self.imageScaling = .scaleAxesIndependently
        }
        return self
    }
    
    @discardableResult
    internal func image(_ image: NSImage?) -> Self {
        self.image = image
        return self
    }
    
    @discardableResult
    internal func symbol(_ name: String, _ variableValue: Double = 1) -> Self {
        let image = NSImage(systemSymbolName: name, variableValue: variableValue, accessibilityDescription: nil)
        return self.image(image)
    }
}
