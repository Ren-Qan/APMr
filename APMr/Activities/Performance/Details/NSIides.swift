//
//  NSISideView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/24.
//

import AppKit

extension IPerformanceView.ICharts {
    class NSISides: NSView  {
        public var target: ISides? = nil
        
        private var sections = 10
        private var currentSelection = -1
        
        fileprivate lazy var table: NSITable = {
            let table = NSITable()
            table.delegate = self
            table.dataSource = self
            table.selectionHighlightStyle = .none
            table.action = #selector(onItemClicked)

            return table
        }()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            self.wantsLayer = true
            addSubview(table.view)
            
            table.add(column: "one", title: "One")
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            table.view.frame = bounds
        }
            
        public func refresh() {
            
        }
    }
}

extension IPerformanceView.ICharts.NSISides: NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if currentSelection > -1 {
            return sections + 10
        }
        return sections
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell: Cell = tableView.reuse(self)
        
        cell.label.textColor = .blue
        if row == currentSelection {
            cell.label.textColor = .orange
        }
        
        if currentSelection > -1, row > currentSelection, row <= currentSelection + 10 {
            cell.label.textColor = .random
            cell.label.stringValue = "  SUB-\(row - currentSelection - 1)"
        } else {
            var padding = 0
            if currentSelection > -1, row > currentSelection + 10 {
                padding = 10
            }
            cell.label.stringValue = "Section - \(row - padding)"
        }
        
        return cell
    }
    
    @objc private func onItemClicked() {
        var row = table.selectedRow
        if currentSelection > -1 {
            if row > currentSelection, row <= currentSelection + 10 {
                return
            }
            if row > currentSelection { row = row - 10 }
        }
        
        var current = currentSelection
        if current == row {
            current = -1
        } else {
            current = row
        }
        
        var inserts = IndexSet()
        var removes = IndexSet()
        
        func indexs(_ start: Int) -> IndexSet {
            var i = IndexSet()
            (0 ..< 10).forEach { s in
                i.insert(s + start + 1)
            }
            return i
        }
        
        if current > -1 {
            inserts = indexs(current)
        }
        
        if self.currentSelection > -1 {
            removes = indexs(self.currentSelection)
        }
        
        self.currentSelection = current
        
        if inserts.count > 0 {
            table.insertRows(at: inserts, withAnimation: .slideDown)
        }
        
        if removes.count > 0 {
            table.removeRows(at: removes, withAnimation: .slideUp)
        }
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {

    }
    
}

extension IPerformanceView.ICharts.NSISides: NSTableViewDataSource {
    
}

extension IPerformanceView.ICharts.NSISides {
    class Cell: NSTableCellView {
        fileprivate lazy var label: NSTextField = {
            let textField = NSTextField()
            textField.isBordered = false
            textField.isEditable = false
            textField.textColor = .random
            textField.alignment = .center
            addSubview(textField)
            return textField
        }()
        
        override func layout() {
            super.layout()
            label.frame = bounds
        }
    }
}
