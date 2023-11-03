//
//  NSILabel+Display.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension NSILabel {
    class Display {
        public var layer: CALayer { content }
        
        fileprivate lazy var content = Layer()
        fileprivate lazy var drawer = Drawer()
        
        public var frame: CGRect = .zero
        
        public var text: String? = nil
        
        public var align: Align = .left
        
        public var lines: Int = 0
        
        public var color: NSColor = .box.H1
        
        public var font: NSFont = .systemFont(ofSize: 11)
        
        public var spacing: CGFloat = 0
        
        init() {
            drawer.closure = { [weak self] layer in
                self?.content.reset()
                self?.content.addSublayer(layer)
            }
        }
    }
}

extension NSILabel.Display {
    public func render() {
        content.reset()
        content.frame = frame
        drawer.frame = frame
        drawer.lines = lines
        
        guard let text, frame.width > 1 else { return }
        
        let range = NSRange(location: 0, length: text.count)
        let string = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.alignment = align.nsAlign
        style.lineSpacing = spacing
        
        string.addAttribute(.font, value: font, range: range)
        string.addAttribute(.foregroundColor, value: color, range: range)
        string.addAttribute(.paragraphStyle, value: style, range: range)
        drawer.render(string)
    }
}


fileprivate extension NSILabel.Display {
    class Layer: CALayer {
        func reset() {
            sublayers?.removeAll { layer in
                layer.removeFromSuperlayer()
                return true
            }
        }
    }
    
    class Drawer {
        var frame: CGRect = .zero
        var lines: Int = 0
        var closure: ((_ layer: CALayer) -> Void)? = nil
        
        func render(_ string: NSAttributedString) {
            let layer = CATextLayer()
            layer.string = string
            layer.frame = frame
            layer.isWrapped = lines != 1
            layer.backgroundColor = NSColor.random.cgColor
            layer.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
            closure?(layer)
        }
    }
}

