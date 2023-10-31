//
//  Chart+Graph.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/31.
//

import AppKit
import Combine

extension CPerformance.Chart.Drawer {
    class Graph {
        fileprivate(set) var axis = Axis()
        fileprivate(set) var series: [Series] = []
        fileprivate(set) var visible: Bool = true
        
        public var inset: NSEdgeInsets { CPerformance.Chart.inset }
        
        public func clean() {
            axis.clean()
            series.forEach { s in
                s.clean()
            }
        }
        
        public func update(_ sources: [CPerformance.Chart.Mark]) {
            if series.count != sources.count {
                series.removeAll()
                
                sources.each { index, _ in
                    let item = Series()
                    series.append(item)
                    return true
                }
            }
             
            axis.update(sources)
            (0 ..< sources.count).forEach { i in
                let series = series[i]
                let source = sources[i]
                series.update(source)
            }
        }
    }
}
