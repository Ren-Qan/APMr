//
//  ITableView+Cell.swift
//  APMr
//
//  Created by 任玉乾 on 2023/8/10.
//

import AppKit

extension IPerformanceView.ITableView {
    class Cell: NSView {
        private var notifier: CPerformance.Chart.Notifier? = nil 
        
        let label = NSTextField()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.backgroundColor = NSColor.random.cgColor
            
            label.isEditable = false
            addSubview(label)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func reload(_ notifier: CPerformance.Chart.Notifier) {
            self.notifier = notifier
            label.frame = bounds
            label.attributedStringValue = .init(string: "\(notifier.type)")
        }
    }
}
