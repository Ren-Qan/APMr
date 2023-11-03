//
//  NSIText.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

class NSIText {
    fileprivate lazy var content = Layer()
    
    fileprivate lazy var storage = Storage()
    
    fileprivate lazy var drawer = Drawer()
    
    fileprivate lazy var flag = Flag()
    
    public var complete: ((CALayer) -> Void)? = nil
        
    init() {
        storage.notice = { [weak self] _, new in
            self?.flag.render.current = new
            self?.sync()
        }
        
        drawer.verify = { [weak self] make in
            make.version = self?.flag.render.current
            make.size = self?.frame.size
            make.lines = self?.lines
            make.spacing = self?.spacing
            make.attribute = self?.create()
        }
        
        drawer.complete = { [weak self] result in
            switch result {
                case .failure: break
                case .success(let layer, let _): self?.complete?(layer)
            }
        }
    }
    
    private func create() -> NSAttributedString? {
        guard let text, frame.width > 1 else { return nil }
        
        let range = NSRange(location: 0, length: text.count)
        let string = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.alignment = align.nsAlign
        style.lineSpacing = spacing
        
        string.addAttribute(.font, value: font, range: range)
        string.addAttribute(.foregroundColor, value: color, range: range)
        string.addAttribute(.paragraphStyle, value: style, range: range)
        return string
    }
    
    private func sync() {
        if flag.render.isNeedRedraw() {
            drawer.setNeedUpdate()
        }
    }
}

extension NSIText {
    public var layer: CALayer { content }
    
    public var frame: CGRect {
        get {
            return storage.frame
        }
        
        set {
            storage.frame = newValue
        }
    }
    
    public var text: String? {
        get {
            return storage.text
        }
        
        set {
            storage.text = newValue
        }
    }
    
    public var align: Align {
        get {
            return storage.align
        }
        
        set {
            storage.align = newValue
        }
    }
    
    public var lines: Int {
        get {
            return storage.lines
        }
        
        set {
            storage.lines = newValue
        }
    }
    
    public var color: NSColor {
        get {
            return storage.color
        }
        
        set {
            storage.color = newValue
        }
    }
    
    public var font: NSFont {
        get {
            return storage.font
        }
        
        set {
            storage.font = newValue
        }
    }
    
    public var spacing: CGFloat {
        get {
            return storage.spacing
        }
        
        set {
            storage.spacing = newValue
        }
    }
}

extension NSIText {
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
