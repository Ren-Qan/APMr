//
//  Cell+PanelSet.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension IPerformanceView.ICharts.NSISides.Cell {
    class PanelSet: NSView {
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
        }
        
        override func layout() {
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ dirtyRect: NSRect) {
            
        }
    }
}

extension IPerformanceView.ICharts.NSISides.Cell.PanelSet {
    public func render(_ value: IPerformanceView.ICharts.NSISides.S) {

    }
}
