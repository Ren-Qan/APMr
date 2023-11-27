//
//  Color+Extensions.swift
//  Fabula
//
//  Created by jasu on 2021/12/08.
//  Copyright (c) 2021 jasu All rights reserved.
//

import SwiftUI

public extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}

extension NSColor {
    static var random: NSColor {
        return NSColor(red: .random(in: 0...1),
                       green: .random(in: 0...1),
                       blue: .random(in: 0...1),
                       alpha: 1)
    }
}
