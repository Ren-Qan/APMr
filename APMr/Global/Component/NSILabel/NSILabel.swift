//
//  NSILabel.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

class NSILabel: NSView {
    // MARK: - Public
    public var lines: Int = 0 {
        didSet {
            let old = oldValue
            let new = lines
            if old != new {
                flag.render.changed()
                sync()
            }
        }
    }
    
    public var text: String? = nil {
        didSet {
            let old = oldValue ?? ""
            let new = text ?? ""
            if old != new {
                flag.render.changed()
                sync()
            }
        }
    }
    
    public var align: Align = .left {
        didSet {
            let old = oldValue
            let new = align
            if old != new {
                flag.render.changed()
                sync()
            }
        }
    }
    
    public var color: NSColor = .box.H1 {
        didSet {
            let old = oldValue
            let new = color
            if old != new {
                flag.render.changed()
                sync()
            }
        }
    }
    
    public var font: NSFont = .systemFont(ofSize: 11) {
        didSet {
            let old = oldValue
            let new = font
            if old != new {
                flag.render.changed()
                sync()
            }
        }
    }
    
    public var spacing: CGFloat = 0 {
        didSet {
            let old = oldValue
            let new = spacing
            if old != new {
                flag.render.changed()
                sync()
            }
        }
    }
    
    // MARK: - Private
    
    fileprivate lazy var flag = Flag()
    fileprivate lazy var display = Display()
    
    // MARK: - Init
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.addSublayer(display.layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        if !self.display.frame.equalTo(layer?.frame ?? .zero) {
            flag.render.changed()
        }
        sync()
    }
}

extension NSILabel {
    fileprivate func sync() {
        redraw()
    }
    
    fileprivate func redraw() {
        guard flag.render.isNeedRedraw() else {
            return
        }
        display.lines = lines
        display.text = text
        display.frame = layer?.frame ?? .zero
        display.align = align
        display.render()
    }
}

extension NSILabel {
    enum Align {
        case left
        case center
        case right
        
        var nsAlign: NSTextAlignment {
            switch self {
                case .left: return .left
                case .center: return .center
                case .right: return .right
            }
        }
    }
}



