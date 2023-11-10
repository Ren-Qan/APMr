//
//  Panel+Headline.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/10.
//

import AppKit

extension IPerformanceView.ICharts.NSISides.PanelSetCell.Panel {
    class Headline: CATextLayer {
        public func update() {
            foregroundColor = NSColor.box.H1.cgColor
            backgroundColor = NSColor.box.BG2.cgColor
        }
        
        public func set(_ value: String) {
            contentsScale = NSScreen.scale
            fontSize = 12.5
            font = NSFont.current.regular(12.5)
            alignmentMode = .left
            string = value
        }
    }
}
