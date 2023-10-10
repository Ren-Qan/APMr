//
//  Cell+Content.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/10.
//

import AppKit

extension IPerformanceView.ITableView.Cell {
    class Content: Layer {
        fileprivate(set) lazy var chart = Chart()
        fileprivate(set) lazy var axis = Axis()
        fileprivate(set) lazy var hint = Hint()
        fileprivate(set) lazy var title = CATextLayer()
                
        override init() {
            super.init()
            addSublayer(chart)
            addSublayer(axis)
            addSublayer(hint)
            addSublayer(title)
            
            self.title.alignmentMode = .center
            self.title.fontSize = 11.5
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
                
        override func layoutSublayers() {
            chart.frame = bounds
            axis.frame = bounds
            hint.frame = bounds
            title.frame = .init(x: (bounds.width - 100) / 2, y: bounds.height - 25, width: 100, height: 20)
        }
    }
}
