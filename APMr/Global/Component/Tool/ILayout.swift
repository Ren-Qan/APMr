//
//  ReFrame.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/15.
//

import AppKit

// MAKR: - Name Space
struct ILayout { }

extension CALayer: ILayoutProtocol {
    func setFrame(rect: CGRect) {
        self.frame = rect
    }
}

extension NSView: ILayoutProtocol {
    func setFrame(rect: CGRect) {
        self.frame = rect
    }
}

protocol ILayoutProtocol {
    var frame: CGRect { get }
    
    func setFrame(rect: CGRect)
}

extension ILayoutProtocol {
    var iLayout: ILayout.Box<Self> {
        return ILayout.Box(targtet: self)
    }
}

extension ILayout {
    struct Box<T: ILayoutProtocol> {
        private var targtet: T
        
        init(targtet: T){
            self.targtet = targtet
        }
        
        @discardableResult
        public func make(_ reference: CGRect,
                         _ closure: (_ maker: Maker) -> Void) -> T {
            let maker = Maker(reference, targtet.frame)
            closure(maker)
            targtet.setFrame(rect: maker.result)
            return targtet
        }
    }
}

extension ILayout {
    class Maker {
        fileprivate enum L {
            case left(InsetPadding)
            case right(InsetPadding)
            case centerH(InsetPadding)
            case top(InsetPadding)
            case bottom(InsetPadding)
            case centerV(InsetPadding)
        }
        
        typealias InsetPadding = CGFloat
        
        fileprivate let targetFrame: CGRect
        fileprivate let referenceFrame: CGRect
        fileprivate var layouts: [L] = []
        
        fileprivate var priorW: CGFloat? = nil
        fileprivate var priorH: CGFloat? = nil
        fileprivate var priorLayoutH: L? = nil
        fileprivate var priorLayoutV: L? = nil
        
        init(_ referenceFrame: CGRect, _ targetFrame: CGRect) {
            self.referenceFrame = referenceFrame
            self.targetFrame = targetFrame
        }
        
        fileprivate var result: CGRect {
            return find() ?? targetFrame
        }
    }
}

extension ILayout.Maker {
    @discardableResult
    public func left(_ padding: InsetPadding) -> Self {
        layouts.append(.left(padding))
        priorLayoutH = .left(padding)
        return self
    }
    
    @discardableResult
    public func centerH(_ padding: InsetPadding) -> Self {
        layouts.append(.centerH(padding))
        priorLayoutH = .centerH(padding)
        return self
    }
    
    @discardableResult
    public func right(_ padding: InsetPadding) -> Self {
        layouts.append(.right(padding))
        priorLayoutH = .right(padding)
        return self
    }
    
    @discardableResult
    public func top(_ padding: InsetPadding) -> Self {
        layouts.append(.top(padding))
        priorLayoutV = .top(padding)
        return self
    }
    
    @discardableResult
    public func centerV(_ padding: InsetPadding) -> Self {
        layouts.append(.centerV(padding))
        priorLayoutV = .centerV(padding)
        return self
    }
    
    @discardableResult
    public func bottom(_ padding: InsetPadding) -> Self {
        layouts.append(.bottom(padding))
        priorLayoutV = .bottom(padding)
        return self
    }
    
    @discardableResult
    public func width(_ value: CGFloat) -> Self {
        priorW = value
        return self
    }
    
    @discardableResult
    public func height(_ value: CGFloat) -> Self {
        priorH = value
        return self
    }
}

extension ILayout.Maker {
    fileprivate func find() -> CGRect? {
        guard let h = priorLayoutH, let v = priorLayoutV else {
            return nil
        }
        
        var l: InsetPadding? = nil
        var r: InsetPadding? = nil
        var t: InsetPadding? = nil
        var b: InsetPadding? = nil
        
        var size = targetFrame.size
        
        layouts.forEach { layout in
            switch layout {
                case .right(let inset): r = inset
                case .left(let inset): l = inset
                case .bottom(let inset): b = inset
                case .top(let inset): t = inset
                default: break
            }
        }
        
        if let width = priorW {
            size.width = width
        } else if let l, let r {
            size.width = referenceFrame.size.width - r - l
        }
        
        if let height = priorH {
            size.height = height
        } else if let t, let b {
            size.height = referenceFrame.size.height - t - b
        }
        
        return make(size, h, v)
    }
    
    private func make(_ size: CGSize, _ h: L, _ v: L) -> CGRect {
        var origin = CGPoint.zero
        switch h {
            case .left(let inset): origin.x = inset
            case .right(let inset): origin.x = referenceFrame.size.width - size.width - inset
            case .centerH(let inset): origin.x = (referenceFrame.size.width - size.width) / 2 + inset
            default: break
        }
        
        switch v {
            case .top(let inset): origin.y = referenceFrame.size.height - size.height - inset
            case .bottom(let inset): origin.y = inset
            case .centerV(let inset): origin.y = (referenceFrame.size.height - size.height) / 2 + inset
            default: break
        }
        
        origin.x += referenceFrame.origin.x
        origin.y += referenceFrame.origin.y
        return CGRect(origin: origin, size: size)
    }
}
