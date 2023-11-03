//
//  Cell+PanelSet.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension IPerformanceView.ICharts.NSISides.Cell {
    class PanelSet: NSView {
        fileprivate lazy var iText = NSIText()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            
            iText.complete = { [weak self] layer in
                layer.backgroundColor = NSColor.random.cgColor
                self?.layer?.addSublayer(layer)
            }
        }
        
        override func layout() {
            iText.frame = bounds
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
        var string = "\(value.timing) S 时刻"
        let count = Int.random(in: 0 ..< 100)
        (100 ..< 100+count).forEach { i in
            string += "\(i)"
        }
        layer?.sublayers?.removeAll(where: { layer in
            layer.removeFromSuperlayer()
            return true
        })
        iText.text = string
    }
}
