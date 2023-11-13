//
//  NSISides+PanelCell.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/9.
//

import AppKit

extension IPerformanceView.ICharts.NSISides {
    class PanelCell: NSCollectionView.Cell {
        fileprivate lazy var panel = Panel()
        fileprivate lazy var separator = Separator()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.layer?.add(panel)
            view.layer?.add(separator)
        }
        
        override func viewDidLayout() {
            panel.frame = view.bounds
            separator.frame = CGRect(x: 35, y: 0, width: view.bounds.width, height: 0.5)
        }
        
        override func updateLayer() {
            view.layer?.backgroundColor = NSColor.box.BG2.cgColor
            separator.backgroundColor = NSColor.box.S2.cgColor
            panel.update()
        }
    }
}

extension IPerformanceView.ICharts.NSISides.PanelCell {
    public func render(_ value: CPerformance.Chart.V) {
        panel.draw(value)
    }
}
