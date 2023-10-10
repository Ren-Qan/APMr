//
//  Cell+Hint.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/10.
//

import AppKit

extension IPerformanceView.ITableView.Cell {
    class Hint: Layer {
        public var strokeColor: CGColor? = nil
        public var fillColor: CGColor? = nil
        
        override func draw(_ configure: IPerformanceView.ITableView.Cell.Layer.Configure) {
            let frame = configure.frame
            let checker = configure.checker
            let offsetX = configure.offset
            let hint = configure.hint
            
            guard checker.hint(hint, offsetX, frame.size.width) else { return }
            
            clear()
            if hint.action == .none { return }
            
            new(frame) { container, layer, path in
                let x = hint.area.origin.x - frame.origin.x - hint.offsetX + offsetX
                layer.lineWidth = 1.5
                layer.lineDashPattern = [5, 1.5]
                layer.masksToBounds = true
                
                if hint.action == .click {
                    path.move(to: .init(x: x, y: 0))
                    path.addLine(to: .init(x: x, y: frame.height))
                } else if hint.action == .drag {
                    let w = hint.area.size.width
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
