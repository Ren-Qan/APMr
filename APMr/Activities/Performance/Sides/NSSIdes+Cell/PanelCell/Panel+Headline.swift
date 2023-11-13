//
//  Panel+Headline.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/10.
//

import AppKit

extension IPerformanceView.ICharts.NSISides.PanelCell.Panel {
    class Headline: CATextLayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
        
        public func update() {
            foregroundColor = NSColor.box.H1.cgColor
        }
        
        public func set(_ value: String) {
            contentsScale = NSScreen.scale
            fontSize = 12.5
            font = NSFont.current.font(12.5, .heavy)
            alignmentMode = .left
            string = value
        }
    }
}
