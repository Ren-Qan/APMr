//
//  NSISides+PanelSetCell.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/9.
//

import AppKit

extension IPerformanceView.ICharts.NSISides {
    class PanelSetCell: NSCollectionView.Cell {
        fileprivate var target: IPerformanceView.ICharts.NSISides.S? = nil
        
        fileprivate lazy var panels: [Panel] = []
        fileprivate lazy var contentLayer = ContentLayer()
        fileprivate lazy var separator = ContentLayer()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.layer?.add(contentLayer)
            view.layer?.add(separator)
        }
        
        override func viewDidLayout() {
            contentLayer.frame = view.bounds
            separator.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 0.5)
        }
        
        override func updateLayer() {
            view.layer?.backgroundColor = NSColor.box.BG2.cgColor
            separator.backgroundColor = NSColor.box.S1.cgColor
        }
    }
}

extension IPerformanceView.ICharts.NSISides.PanelSetCell {
    public func render(_ shot: IPerformanceView.ICharts.NSISides.S) {
        if target === shot {
            return
        }
        target = shot
        adjust(shot)
        draw(shot)
    }
}

extension IPerformanceView.ICharts.NSISides.PanelSetCell {
    fileprivate func adjust(_ shot: IPerformanceView.ICharts.NSISides.S) {
        let count = shot.values.count - panels.count
        guard count > 0 else { return }
        
        (0 ..< count).forEach { _ in
            let panel = Panel()
            contentLayer.add(panel)
            panels.append(panel)
        }
    }
    
    fileprivate func draw(_ shot: IPerformanceView.ICharts.NSISides.S) {
        var y: CGFloat = shot.sideCellExpandHeight
        (0 ..< panels.count).forEach { index in
            let panel = self.panels[index]
            if index < shot.values.count {
                let value = shot.values[index]
                let height = value.sidePartViewHeight
                panel.isHidden = false
                panel.draw(value)
                y -= height
                panel.frame = CGRect(x: 0, y: y, width: shot.sideCellWidth, height: height)
            } else {
                panel.isHidden = true
            }
        }
    }
}

extension IPerformanceView.ICharts.NSISides.PanelSetCell {
    fileprivate class ContentLayer: CALayer {
        
    }
}
