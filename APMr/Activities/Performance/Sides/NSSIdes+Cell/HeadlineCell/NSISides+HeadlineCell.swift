//
//  NSISides+HeadlineCell.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/9.
//

import AppKit

extension IPerformanceView.ICharts.NSISides {
    class HeadlineCell: NSCollectionView.Cell {
        fileprivate lazy var icon = NSImageView()
        fileprivate lazy var label = Headline().common.font(14, .current.medium(14))
        fileprivate lazy var separator = Separator()
                
        override func viewDidLoad() {
            super.viewDidLoad()
            view.adds([icon])
            view.layer?.adds([label, separator])
        }
        
        override func updateLayer() {
            view.layer?.background(.box.BG2)
            separator.background(.box.S1)
            label.color(.box.H1)
        }
        
        override func viewDidLayout() {
            icon.iLayout.make(view.bounds) { maker in
                maker.left(15).centerV(0).width(13).height(13)
            }
            
            separator.iLayout.make(view.bounds) { maker in
                maker.left(0).right(0).bottom(0).height(0.5)
            }
            
            label.iFit().iLayout.make(view.bounds) { maker in
                maker.left(35).centerV(0)
            }
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

extension IPerformanceView.ICharts.NSISides.HeadlineCell {
   fileprivate class Headline: CATextLayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
}
