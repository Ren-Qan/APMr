//
//  NSIText+Flag.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import Foundation

extension NSIText {
    class Flag {
        fileprivate(set) lazy var render = Render()
    }
}

extension NSIText.Flag {
    class Render {
        var current: Int = 0
        var last: Int = 0
                
        public func isNeedRedraw(_ sync: Bool = true) -> Bool {
            let redraw = last != current
            if sync { current = last }
            return redraw
        }
    }
}
