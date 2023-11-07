//
//  Cell+Headline.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension IPerformanceView.ICharts.NSISides.Cell {
    class Headline: NSView {
        fileprivate lazy var icon: NSImageView = {            
            return NSImageView()
                .symbol("chevron.right")
                .mode(.fit)
        }()
        
        fileprivate lazy var label: NSILabel = {
            return NSILabel()
                .vertical(.center)
                .horizontal(.left)
                .color(.box.H1)
        }()
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            adds([label, icon])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            label.frame(CGRect(x: 35, y: 0, width: bounds.width - 35, height: bounds.height))
            icon.frame(CGRect(x: 10, y: (bounds.height - 13) / 2, width: 13, height: 13))
        }
    }
}

extension IPerformanceView.ICharts.NSISides.Cell.Headline {
    public func render(_ value: IPerformanceView.ICharts.NSISides.S) {
        label.text("\(value.timing)S 时刻数据")
    }
}
