//
//  IFont.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/8.
//

import AppKit

extension NSFont {
    static var current: IFonts = .momo
}

enum IFonts {
    case momo
    case `default`
    
    func medium(_ size: CGFloat) -> NSFont {
        return font(size, .medium)
    }
    
    func regular(_ size: CGFloat) -> NSFont {
        return font(size, .regular)
    }
    
    func font(_ size: CGFloat, _ weight: NSFont.Weight) -> NSFont {
        switch self {
            case .default: return .systemFont(ofSize: size, weight: weight)
                
            case .momo: return .monospacedSystemFont(ofSize: size, weight: weight)
        }
    }
}
