//
//  Chart+Axis.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/31.
//

import AppKit
import Combine

extension CPerformance.Chart.Drawer.Graph {
    class Axis {
        fileprivate(set) var upper: CPerformance.Chart.Mark? = nil
        fileprivate(set) var count = 0
        
        public var width: CGFloat { CPerformance.Chart.width }
        
        public func clean() {
            upper = nil
            count = 0
        }
        
        public func update(_ sources: [CPerformance.Chart.Mark]) {
            self.count += 1
            
            let max = sources.max { l, r in
                return l.source.value < r.source.value
            }
            
            if (max?.source.value ?? 0) > (upper?.source.value ?? 0) {
                upper = max
            }
        }
    }
}
