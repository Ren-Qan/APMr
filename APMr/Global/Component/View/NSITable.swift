//
//  NSITable.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/25.
//

import AppKit

class NSITable: NSTableView {
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
        scrollView.documentView = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NSTableView {
    typealias Cell = NSTableCellView
    
    func reuse<T : Cell>(_ owner: Any?) -> T {
        let id = NSUserInterfaceItemIdentifier(NSStringFromClass(T.self))
        var cell = makeView(withIdentifier: id, owner: owner) as? T
        
        if cell == nil {
            cell = T()
            cell?.identifier = id
        }
        
        return cell!
    }
}

extension NSITable {
    @discardableResult
    public func add(column: String, title: String) -> NSTableColumn {
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(column))
        column.title = title
        addTableColumn(column)
        return column
    }
}
