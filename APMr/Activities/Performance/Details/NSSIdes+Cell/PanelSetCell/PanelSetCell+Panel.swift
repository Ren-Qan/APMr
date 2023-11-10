//
//  Cell+Panel.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension IPerformanceView.ICharts.NSISides.PanelSetCell {
    class Panel: CALayer {
        fileprivate lazy var headline = Headline()
        fileprivate lazy var separator = IPerformanceView.ICharts.NSISides.Separator()
        fileprivate lazy var rows = [NoteRow]()
        
        override init() {
            super.init()
            layoutManager = CAConstraintLayoutManager()
            headline.addConstraint(CAConstraint(attribute: .midY, relativeTo: "superlayer", attribute: .maxY, offset: -17.5))
            headline.addConstraint(CAConstraint(attribute: .minX, relativeTo: "superlayer", attribute: .minX, offset: 35))
            adds([headline, separator])
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSublayers() {
            super.layoutSublayers()
            separator.frame = .init(x: 35, y: 0, width: bounds.width - 35, height: 0.5)
            var y = frame.height - 35
            rows.forEach { row in
                y -= 30
                row.frame = CGRect(x: 35, y: y, width: bounds.width - 35, height: 30)
            }
        }
    }
}

extension IPerformanceView.ICharts.NSISides.PanelSetCell.Panel {    
    public func draw(_ value: CPerformance.Chart.V) {
        headline.set(value.type.headline)
        config(value)
        rows[0].load(["指标", "值", "单位"])
        (0 ..< value.marks.count).forEach { i in
            rows[1 + i].load(value.marks[i])
        }
    }
    
    private func config(_ value: CPerformance.Chart.V) {
        let count = value.marks.count + 1 - rows.count
        guard count > 0 else { return }
        (rows.count ..< value.marks.count + 1).forEach { i in
            let row = NoteRow()
            rows.append(row)
            add(row)
        }
    }
        
    public func update() {
        separator.backgroundColor = NSColor.box.S1.cgColor
        headline.update()
        rows.forEach { row in
            row.update()
        }
    }
}

extension IPerformanceView.ICharts.NSISides.PanelSetCell.Panel {
    
}
