//
//  Cell+Chart.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/10.
//

import Foundation
import AppKit

extension IPerformanceView.ICharts.Cell {
    class Chart: Layer {
        public var styles: [CGColor] = []
        
        override func draw(_ configure: IPerformanceView.ICharts.Cell.Layer.Configure) {
            let graph = configure.graph
            let frame = configure.frame
            let checker = configure.checker
            let offsetX = configure.actor.displayer.mutate.offsetX
            
            let w = graph.axis.width
            var l = Int((-offsetX) / graph.axis.width)
            var r = l + Int(frame.size.width / w) + 4
            if l < 0 { l = 0 }
            if r > graph.axis.count { r = graph.axis.count }
            
            guard l < r else { return }
            guard checker.chart(l, r, offsetX) else { return }
            
            clear()
            var tasks: [(() -> Void)] = []
            graph.series.each { i, series in
                self.new(frame) { container, layer, path in
                    let r = min(r, series.marks.count)
                    layer.masksToBounds = true
                    series.marks[l ..< r].each { index, element in
                        let x: CGFloat = CGFloat(index + l) * w + offsetX
                        let y: CGFloat = element.source.value / (graph.axis.upper?.source.value ?? 1) * frame.height
                        let point = CGPoint(x: x, y: y)
                        
                        if index == 0 {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                        
                        return x < frame.width + graph.inset.horizontal
                    }
                    
                    if styles.count > i {
                        tasks.append { [weak self] in
                            layer.strokeColor = self?.styles[i]
                        }
                    }
                }
                return true
            }
            
            self.style {
                tasks.forEach{ $0() }
            }
            self.sync()
        }
    }
}
