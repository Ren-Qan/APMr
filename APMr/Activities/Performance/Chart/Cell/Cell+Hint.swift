//
//  Cell+Hint.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/10.
//

import AppKit

extension IPerformanceView.ICharts.Cell {
    class Hint: Layer {
        public var strokeColor: CGColor? = nil
        public var fillColor: CGColor? = nil
        
        override func draw(_ configure: IPerformanceView.ICharts.Cell.Layer.Configure) {
            let frame = configure.frame
            let checker = configure.checker
            let hint = configure.actor.hilighter.hint
            let offsetX = configure.actor.displayer.mutate.offsetX
            
            guard checker.hint(hint, offsetX, frame.size.width) else { return }
            
            clear()
            guard hint.action != .none,
                  let begin = hint.begin,
                  let end = hint.end else {
                return
            }
            
            new(frame) { container, layer, path in
                let x = begin.location.x - frame.origin.x - begin.offset + offsetX
                layer.lineWidth = 1.5
                layer.lineDashPattern = [5, 1.5]
                layer.masksToBounds = true
                
                if hint.action == .click {
                    path.move(to: .init(x: x, y: 0))
                    path.addLine(to: .init(x: x, y: frame.height))
                } else if hint.action == .drag {
                    let endX = end.location.x - frame.origin.x - end.offset + offsetX
                    let w = endX - x
                    path.addRect(.init(x: x, y: 0, width: w, height: frame.height))
                }
                
                let isDrag = hint.action == .drag
                container.style { [weak self] in
                    layer.strokeColor = self?.strokeColor
                    if isDrag {
                        layer.fillColor = self?.fillColor
                    }
                }
                container.sync()
            }
        }
    }
}
