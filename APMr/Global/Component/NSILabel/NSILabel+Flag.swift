//
//  NSILabel+Flag.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import Foundation

extension NSILabel {
    class Flag {
       fileprivate(set) lazy var render = Render()
    }
}

extension NSILabel.Flag {
    class Render {
        fileprivate var last = 0
        fileprivate var current = 0
        
        public func changed() {
            current += 1
        }
        
        public func isNeedRedraw(_ sync: Bool = true) -> Bool {
            let redraw = last != current
            if sync { current = last }
            return redraw
        }
    }
}
