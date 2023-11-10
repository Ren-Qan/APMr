//
//  NSISides+HeadlineCell.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/9.
//

import AppKit

extension IPerformanceView.ICharts.NSISides {
    class HeadlineCell: NSCollectionView.Cell {
        fileprivate lazy var icon: NSImageView = {
            let view = NSImageView()
            return view
        }()
        
        fileprivate lazy var label: NSILabel = {
            return NSILabel()
                .font(.current.medium(14))
                .vertical(.center)
                .horizontal(.left)
                .color(.box.H1)
        }()
        
        fileprivate lazy var separator = Separator()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.adds([label, icon])
            view.layer?.add(separator)
        }
        
        override func updateLayer() {
            view.layer?.backgroundColor = NSColor.box.BG2.cgColor
            separator.backgroundColor = NSColor.box.S1.cgColor
        }
        
        override func viewDidLayout() {
            icon.frame = CGRect(x: 15, y: (view.bounds.height - 13) / 2, width: 13, height: 13)
            separator.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 0.5)
            label.frame = CGRect(x: 35, y: 0, width: view.bounds.width, height: view.bounds.height)
        }
    }
}

extension IPerformanceView.ICharts.NSISides.HeadlineCell {
    public func render(_ value: IPerformanceView.ICharts.NSISides.S) {
        label.text("\(value.timing)S 时刻数据")
        icon.symbol("chevron." + (value.expand ? "down" : "right"))
        separator.isHidden = value.expand
    }
}
