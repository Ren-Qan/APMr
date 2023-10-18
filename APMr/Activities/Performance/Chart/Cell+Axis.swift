//
//  Cell+Axis.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/10.
//

import AppKit

extension IPerformanceView.ITableView.Cell {
    class Axis: Layer {
        public var lineColor: CGColor? = nil
        public var textColor: CGColor? = nil
        
        override func draw(_ configure: IPerformanceView.ITableView.Cell.Layer.Configure) {
            let graph = configure.graph
            let frame = configure.frame
            let checker = configure.checker
            let offsetX = configure.offset
            
            let count = Int(frame.width / graph.axis.width) + 2
            let upper = graph.axis.upper?.source.value ?? 0
            guard checker.axis(frame.width, offsetX, count, upper) else { return }
            var l = Int((-offsetX) / graph.axis.width)
            if l < 0 { l = 0 }
            let w = graph.axis.width
            
            clear()
            new(frame) { container, layer, path in
                let LW: CGFloat = 1.5
                layer.masksToBounds = true
                layer.lineWidth = LW

                // Y
                let x = graph.inset.left
                path.move(to: .init(x: x, y: graph.inset.bottom))
                path.addLine(to: .init(x: x, y: frame.height - graph.inset.top))
                path.addLine(to: .init(x: x - 5, y: frame.height - graph.inset.top))

                let yText = Text()
                yText.fontSize = 10
                yText.alignmentMode = .center
                yText.string = String(format: "%.1f", upper)
                yText.frame = .init(x: x - 50, y: frame.height - 15, width: 100, height: 10)
                layer.addSublayer(yText)
                
                // X
                var texts: [CATextLayer] = []
                (0 ..< count).each { _, padding in
                    let index = l + padding
                    var x = CGFloat(index) * w + graph.inset.left + offsetX
                    if x < graph.inset.left { x = graph.inset.left }
                    let point = CGPoint(x: x, y: graph.inset.bottom)
                    if padding == 0 {
                        path.move(to: point)
                    } else {
                        path.addLine(to: point)
                    }
                    
                    let timing = TimeInterval(index) * CPerformance.interval
                    guard (Int(timing * 10) % 50 == 0) || padding == 0 else {
                        return x < frame.width + graph.inset.horizontal
                    }
                    
                    path.addLine(to: .init(x: x, y: graph.inset.bottom - 6))
                    path.move(to: point)
                    
                    let text = Text()
                    text.fontSize = 10
                    text.alignmentMode = .center
                    
                    text.string = "\(Int(timing)) s"
                    text.frame = .init(x: x - 25, y: graph.inset.bottom - 16, width: 50, height: 10)
                    layer.addSublayer(text)
                    
                    texts.append(text)
                    return x < frame.width + graph.inset.horizontal
                }
                
                // Style
                container.style { [weak self] in
                    layer.strokeColor = self?.lineColor
                    yText.foregroundColor = self?.textColor
                    texts.forEach { text in
                        text.foregroundColor = self?.textColor
                    }
                }
                container.sync()
            }
        }
    }
}
