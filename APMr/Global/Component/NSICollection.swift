//
//  NSICollection.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/27.
//

import AppKit
import SwiftUI

class NSICollection: NSCollectionView {
    public var view: NSScrollView {
        return scrollView
    }
    
    fileprivate lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.drawsBackground = false
        scrollView.hasHorizontalScroller = true
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        return scrollView
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        scrollView.documentView = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSCollectionView {
    typealias Section = NSView & NSCollectionViewElement
    typealias Cell = BaseCell
    
    enum S {
        case header
        case footer
        var value: String {
            switch self {
                case .header: return NSCollectionView.elementKindSectionHeader
                case .footer: return NSCollectionView.elementKindSectionFooter
            }
        }
    }
    
    func register(_ section: S, _ viewClass: Section.Type) {
        let id = NSUserInterfaceItemIdentifier(NSStringFromClass(viewClass.self))
        register(viewClass, forSupplementaryViewOfKind: section.value, withIdentifier: id)
    }
        
    func register(cell: Cell.Type) {
        let id = NSUserInterfaceItemIdentifier(NSStringFromClass(cell.self))
        register(cell, forItemWithIdentifier: id)
    }
}

extension NSCollectionView {
    func reuse<T: NSCollectionViewItem>(_ indexPath: IndexPath) -> T {
        let id = NSUserInterfaceItemIdentifier(NSStringFromClass(T.self))
        return makeItem(withIdentifier: id, for: indexPath) as! T
    }
    
    func reuse<T: NSView & NSCollectionViewElement>(_ section: S, _ indexPath: IndexPath) -> T {
        let id = NSUserInterfaceItemIdentifier(NSStringFromClass(T.self))
        return makeSupplementaryView(ofKind: section.value, withIdentifier: id, for: indexPath) as! T
    }
}

extension NSCollectionView {
    func register(cells: [Cell.Type]) {
        cells.forEach { cell in
            register(cell: cell)
        }
    }
    
    func register(header: Section.Type) {
        register(.header, header)
    }
    
    func register(headers: [Section.Type]) {
        headers.forEach { header in
            register(header: header)
        }
    }
    
    func register(footer: Section.Type) {
        register(.footer, footer)
    }
    
    func register(footers: [Section.Type]) {
        footers.forEach { footer in
            register(footer: footer)
        }
    }
}

extension NSCollectionView {
    class BaseCell: NSCollectionViewItem {
        override func loadView() {
            let view = NSView()
            view.wantsLayer = true
            self.view = view
        }
    }
}
