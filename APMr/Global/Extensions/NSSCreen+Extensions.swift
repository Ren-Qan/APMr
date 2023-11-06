//
//  NSSCreen+Extensions.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/6.
//

import AppKit

extension NSScreen {
    static var scale: CGFloat = {
        var scale: CGFloat = 1
        NSScreen.screens.forEach { screen in
            if screen.backingScaleFactor > scale {
                scale = screen.backingScaleFactor
            }
        }
        return scale
    }()
}
