//
//  NSIText+Drawer.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension NSIText {
    class Drawer {
        fileprivate var isDrawing = false
        var verify: ((Maker) -> Void)? = nil
        var complete: ((R) -> Void)? = nil
    }
}

extension NSIText.Drawer {
    func setNeedUpdate() {
        if isDrawing { return }
        self.isDrawing = true
        DispatchQueue.main.async {
            self.draw()
            self.isDrawing = false
        }
    }
}

extension NSIText.Drawer {
    fileprivate func draw() {
        let maker = Maker()
        verify?(maker)
        guard maker.vaild else {
            complete?(.failure)
            return
        }
        
        let graph = graph(maker.lines!, maker.size!, maker.attribute!)
        let layer = shape(maker.size!, graph)
        complete?(.success(layer, maker.version!))
    }
    
    private func graph(_ max: Int, _ size: CGSize, _ string: NSAttributedString) -> Graph {
        let setter = CTTypesetterCreateWithAttributedString(string)
        
        var maxLine = max
        if max <= 0 { maxLine = .max }
        
        var height: CGFloat = 0
        var index = 0
        var lines: [L] = []
        
        while index < string.length {
            let count = CTTypesetterSuggestLineBreak(setter, index, size.width)
            let source = CTTypesetterCreateLine(setter, .init(location: index, length: count))
            
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            CTLineGetTypographicBounds(source, &ascent, &descent, &leading)
            
            let line = L(line: source, ascent: ascent, descent: descent, leading: leading)
            index += count
            height += ascent + descent + leading
            
            if lines.count <= maxLine, height <= size.height {
                lines.append(line)
            } else {
                height -= ascent + descent + leading
                break
            }
        }
        
        return Graph(lines: lines,
                     contentSize: CGSize(width: size.width,
                                         height: height))
    }
    
    private func shape(_ size: CGSize, _ graph: Graph) -> CALayer {
        let layer = La()
        layer.frame.size = graph.contentSize
        layer.frame.origin.y = (size.height - graph.contentSize.height) / 2
        layer.graph = graph
        layer.setNeedsDisplay()
        
        return layer
    }
}

extension NSIText.Drawer {
    class Maker {
        var attribute: NSAttributedString? = nil
        var version: Int? = nil
        var size: CGSize? = nil
        var lines: Int? = nil
        var spacing: CGFloat? = nil
        
        fileprivate var vaild: Bool {
            guard let attribute, attribute.length > 1,
                  let size, size.width > 1, size.height > 1,
                  version != nil,
                  lines != nil,
                  spacing != nil else {
                return false
            }
            return true
        }
    }
}

extension NSIText.Drawer {
    enum R {
        case success(CALayer, Int)
        case failure
    }
    
    struct Graph {
        let lines: [L]
        let contentSize: CGSize
    }
    
    struct L {
        let line: CTLine
        let ascent: CGFloat
        let descent: CGFloat
        let leading: CGFloat
    }
    
    class La: CALayer {
        var graph: Graph? = nil
        override func draw(in ctx: CGContext) {
            super.draw(in: ctx)
            guard let graph else { return }
            let context = ctx
            context.textMatrix = .identity
//            context.translateBy(x: 0, y: graph.contentSize.height)
//            context.scaleBy(x: 1, y: -1)
            
            var y = graph.contentSize.height
            graph.lines.forEach { line in
                y -= line.ascent
                context.textPosition = .init(x: 0, y: y)
                y -= (line.descent + line.leading)
                CTLineDraw(line.line, context)
            }
            contents = context.makeImage()
        }
    }
}
