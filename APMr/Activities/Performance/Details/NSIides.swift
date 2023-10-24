//
//  NSISideView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/24.
//

import AppKit

extension IPerformanceView.ICharts {
    class NSISides: NSView {
        public var target: ISides? = nil
        
        override func layout() {

        }
        
        public func refresh() {
            
        }
    }
}

extension IPerformanceView.ICharts.ISides {
    class List: NSView {
        lazy var tableView = NSTableView()
    }
}
