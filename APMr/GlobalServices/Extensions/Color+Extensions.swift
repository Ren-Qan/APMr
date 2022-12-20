//
//  Color+Extensions.swift
//  Fabula
//
//  Created by jasu on 2021/12/08.
//  Copyright (c) 2021 jasu All rights reserved.
//

import SwiftUI

public extension Color {
    static var fabulaBack0: Color { Color(#function, bundle: .main) }
    static var fabulaBack1: Color { Color(#function, bundle: .main) }
    static var fabulaBack2: Color { Color(#function, bundle: .main) }
    static var fabulaFore1: Color { Color(#function, bundle: .main) }
    static var fabulaFore2: Color { Color(#function, bundle: .main) }
    static var fabulaPrimary: Color { Color(#function, bundle: .main) }
    static var fabulaSecondary: Color { Color(#function, bundle: .main) }
    static var fabulaBar1: Color { Color(#function, bundle: .main) }
    static var fabulaBar2: Color { Color(#function, bundle: .main) }
    static var fabulaForeWB100: Color { Color(#function, bundle: .main) }
    static var fabulaBackWB100: Color { Color(#function, bundle: .main) }
}

public extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
