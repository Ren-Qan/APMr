//
//  Cell+Panel.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension IPerformanceView.ICharts.NSISides.PanelSetCell {
    class Panel: CALayer {
        
    }
}

extension IPerformanceView.ICharts.NSISides.PanelSetCell.Panel {    
    public func draw(_ value: CPerformance.Chart.V) {
        backgroundColor = NSColor.random.cgColor
    }
}
