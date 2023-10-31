//
//  Chart+Series.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/31.
//

import AppKit
import Combine

extension CPerformance.Chart.Drawer.Graph {
    class Series: Identifiable {
        fileprivate(set) var marks: [CPerformance.Chart.Mark] = []
        fileprivate(set) var visible: Bool = true
                
        public func clean() {
            marks.removeAll()
        }
        
        public func update(_ source: CPerformance.Chart.Mark) {
            marks.append(source)
        }
    }
}
