//
//  NSIText.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/6.
//

import AppKit

class NSIText {
    private(set) lazy var layer = NSIText.Layer()
    public var complete: ((NSIText) -> Void)? = nil
    
    public var text: String? = nil {
        didSet {
            let old = oldValue ?? ""
            let new = text ?? ""
            
            if new != old {
                sync()
            }
        }
    }
    
    public var color: NSColor = .textColor {
        didSet {
            sync()
        }
    }
    
    public var align: Align = .left {
        didSet {
            if oldValue != align {
                sync()
            }
        }
    }
    
    public var isWrapped: Bool = true {
        didSet {
            if oldValue != isWrapped {
                sync()
            }
        }
    }
    
    public var spacing: CGFloat = 0 {
        didSet {
            if oldValue != spacing {
                sync()
            }
        }
    }
    
    public var font: NSFont = .current.regular(14) {
        didSet {
            if oldValue != font {
                sync()
            }
        }
    }
    
    public var attribute: NSAttributedString? = nil {
        didSet {
            sync()
        }
    }
    
    public var container: Container = .unlimit {
        didSet {
            let old = oldValue.size
            let new = container.size
            if old.equalTo(new).counter, new.width > 1, new.height > 1 {
                sync()
            }
        }
    }
    
    public func reload() {
        sync()
    }
}

extension NSIText {
    fileprivate func sync() {
        let container = container.size
        guard let attribute = renderAttribute(), container.width > 1, container.height > 1 else {
            return
        }
        
        let size = attribute.boundingRect(with: container, options: .usesLineFragmentOrigin).size
        layer.frame.size = size
        layer.contentsScale = NSScreen.scale
        layer.isWrapped = isWrapped
        layer.string = attribute
        
        complete?(self)
    }
    
    private func renderAttribute() -> NSAttributedString? {
        if let attribute {
            return attribute
        }
        
        if let text {
            let range = NSRange(location: 0, length: text.count)
            let style = NSMutableParagraphStyle()
            let attribute = NSMutableAttributedString(string: text)
            
            style.alignment = align.nsAlign
            style.lineSpacing = spacing
            style.lineBreakMode = .byWordWrapping
            
            attribute.addAttribute(.font, value: font, range: range)
            attribute.addAttribute(.foregroundColor, value: color.cgColor, range: range)
            attribute.addAttribute(.paragraphStyle, value: style, range: range)
            return attribute
        }
        
        return nil
    }
}

extension NSIText {
    enum Container {
        case unlimit
        case width(CGFloat)
        case height(CGFloat)
        case area(CGSize)
        
        fileprivate var size: CGSize {
            let max: CGFloat = .greatestFiniteMagnitude
            switch self {
                case .unlimit: return .init(width: max, height: max)
                case .width(let w): return .init(width: w, height: max)
                case .height(let h): return .init(width: max, height: h)
                case .area(let size): return size
            }
        }
    }
    
    enum Align {
        case left
        case center
        case right
        
        fileprivate var nsAlign: NSTextAlignment {
            switch self {
                case .left: return .left
                case .center: return .center
                case .right: return .right
            }
        }
    }
}
