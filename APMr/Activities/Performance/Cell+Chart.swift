//
//  Cell+Chart.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/10.
//

import Foundation

extension IPerformanceView.ITableView.Cell {
    class Chart: Layer {
        override func draw(_ configure: IPerformanceView.ITableView.Cell.Layer.Configure) {
            let graph = configure.graph
            let frame = configure.frame
            let checker = configure.checker
            let offsetX = configure.offset
            
            let w = graph.axis.width
            var l = Int((-offsetX) / graph.axis.width)
            var r = l + Int(frame.size.width / w) + 4
            if l < 0 { l = 0 }
            if r > graph.axis.count { r = graph.axis.count }
            
            guard l < r else { return }
            guard checker.chart(l, r, offsetX) else { return }
            
            clear()
            graph.series.forEach { series in
                new(frame) { container, layer, path in
                    let r = min(r, series.sources.count)
                    layer.masksToBounds = true
                    layer.strokeColor = series.style.cgColor
                    
                    series.sources[l ..< r].each { index, element in
                        let x: CGFloat = CGFloat(index + l) * w + offsetX
                        let y: CGFloat = element.value / (graph.axis.upper?.value ?? 1) * frame.height
                        let point = CGPoint(x: x, y: y)
                        
                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                        
                        return x < frame.width + graph.inset.horizontal
                    }
                    
                    container.style {
                        layer.strokeColor = series.style.cgColor
                    }
                }
            }
        }
    }
}
