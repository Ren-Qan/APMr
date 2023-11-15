//
//  NSILabel.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

class NSILabel: NSView {
    // MARK: - Public
    public var adjust = Adjust() {
        didSet {
            graphAdjust()
        }
    }
    
    // MARK: - Private
    fileprivate lazy var iText = NSIText()
    
    // MARK: - Init
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.addSublayer(iText.layer)
        iText.complete = { [weak self] _ in
            self?.graphAdjust()
        }
    }
    
    override func layout() {
        iText.container = .area(bounds.size)
        graphAdjust()
    }
    
    override func updateLayer() {
        iText.reload()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSILabel {
    fileprivate func graphAdjust() {
        let size = iText.layer.frame.size
        func h() -> CGFloat {
            var x: CGFloat = 0
            switch adjust.horizontal {
                case .left: x = 0
                case .center: x = (bounds.width - size.width) / 2
                case .right: x = bounds.width - size.width
            }
            return x
        }
        
        func v() -> CGFloat {
            var y: CGFloat = 0
            switch adjust.vertical {
                case .top: y = bounds.height - size.height
                case .center: y = (bounds.height - size.height) / 2
                case .bottom: y = 0
            }
            return y
        }
        
        let x = h()
        let y = v()
        iText.layer.frame.origin = .init(x: x, y: y)
    }
}

extension NSILabel {
    struct Adjust {
        enum H {
            case left
            case center
            case right
        }
        
        enum V {
            case top
            case center
            case bottom
        }
        
        var vertical: V = .center
        var horizontal: H = .center
    }
}

extension NSILabel {
    public var text: String? {
        set {
            iText.text = newValue
        }
        
        get {
            iText.text
        }
    }
    
    public var color: NSColor {
        set {
            iText.color = newValue
        }
        
        get {
            iText.color
        }
    }
    
    public var align: NSIText.Align {
        set {
            iText.align = newValue
        }
        
        get {
            iText.align
        }
    }
    
    public var isWrapped: Bool {
        set {
            iText.isWrapped = newValue
        }
        
        get {
            iText.isWrapped
        }
    }
    
    public var spacing: CGFloat {
        set {
            iText.spacing = newValue
        }
        
        get {
            iText.spacing
        }
    }
    
    public var font: NSFont {
        set {
            iText.font = newValue
        }
        
        get {
            iText.font
        }
    }
    
    public var attribute: NSAttributedString? {
        set {
            iText.attribute = newValue
        }
        
        get {
            iText.attribute
        }
    }
}

extension NSILabel {
    @discardableResult
    public func horizontal(_ value: NSILabel.Adjust.H) -> Self {
        self.adjust.horizontal = value
        return self
    }
    
    @discardableResult
    public func vertical(_ value: NSILabel.Adjust.V) -> Self {
        self.adjust.vertical = value
        return self
    }
}

extension NSILabel {
    @discardableResult
    public func text(_ value: String) -> Self {
        self.iText.text = value
        return self
    }
    
    @discardableResult
    public func color(_ value: NSColor) -> Self {
        self.iText.color = value
        return self
    }
    
    @discardableResult
    public func align(_ value: NSIText.Align) -> Self {
        self.iText.align = value
        return self
    }
    
    @discardableResult
    public func wrapped(_ value: Bool) -> Self {
        self.iText.isWrapped = value
        return self
    }

    @discardableResult
    public func spacing(_ value: CGFloat) -> Self {
        self.iText.spacing = value
        return self
    }
    
    @discardableResult
    public func font(_ value: NSFont) -> Self {
        self.iText.font = value
        return self
    }

    @discardableResult
    public func container(_ value: NSIText.Container) -> Self {
        self.iText.container = value
        return self
    }
}
