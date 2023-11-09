//
//  NSISides+HeadlineCell.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/9.
//

import AppKit
import SnapKit

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
            
            icon.snp.makeConstraints { make in
                make.centerX.equalTo(view.snp.left).offset(18)
                make.centerY.equalToSuperview()
            }
            
            label.snp.makeConstraints { make in
                make.bottom.height.right.equalToSuperview()
                make.left.equalToSuperview().offset(35)
            }
        }
        
        override func updateLayer() {
            view.layer?.backgroundColor = NSColor.box.BG2.cgColor
            separator.backgroundColor = NSColor.box.S1.cgColor
        }
        
        override func viewDidLayout() {
            separator.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 0.5)
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
