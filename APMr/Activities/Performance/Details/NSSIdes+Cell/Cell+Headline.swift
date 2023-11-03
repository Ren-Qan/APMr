//
//  Cell+Headline.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension IPerformanceView.ICharts.NSISides.Cell {
    class Headline: NSView {
        fileprivate lazy var label = NSILabel()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            add(label)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            label.frame = bounds
        }
    }
}

extension IPerformanceView.ICharts.NSISides.Cell.Headline {
    public func render(_ value: IPerformanceView.ICharts.NSISides.S) {
        var string = "\(value.timing) S 时刻"
        let count = Int.random(in: 0 ..< 100)
        (100 ..< 100+count).forEach { i in
            string += "\(i)"
        }
        label.text = string
    }
}
