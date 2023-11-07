//
//  IColors+NSColor.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/2.
//

import AppKit

extension NSColor: IColorsBoxProtocol {
    typealias Maker = NSIColorMaker
    
    static var box = IColorBox<Maker>()
}

struct NSIColorMaker: IColorsMakerProtocol {
    typealias Color = NSColor
    static func color(_ name: String) -> Color {
        return Color(named: name)!
    }
}
