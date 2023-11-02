//
//  IColors+Color.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/2.
//

import SwiftUI

extension Color: IColorsBoxProtocol {
    typealias Maker = IColorMaker
    
    static var box = IColorBox<Maker>()
}

struct IColorMaker: IColorsMakerProtocol {
    typealias Color = SwiftUI.Color
    static func color(_ name: String) -> Color {
        return Color(name)
    }
}
