//
//  Cell+Panel.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/3.
//

import AppKit

extension IPerformanceView.ICharts.NSISides.PanelCell {
    class Panel: CALayer {
        fileprivate lazy var headline = Headline()
        fileprivate lazy var rows = [NoteRow]()
        fileprivate lazy var separator = IPerformanceView.ICharts.NSISides.Separator()
        
        override init() {
            super.init()
            layoutManager = CAConstraintLayoutManager()
            headline.addConstraint(CAConstraint(attribute: .midY, relativeTo: "superlayer", attribute: .maxY, offset: -17.5))
            headline.addConstraint(CAConstraint(attribute: .minX, relativeTo: "superlayer", attribute: .minX, offset: 35))
            adds([headline, separator])
        }
        
        override init(layer: Any) {
            super.init(layer: layer)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSublayers() {
            super.layoutSublayers()
            separator.frame = .init(x: 25, y: 0, width: bounds.width - 35, height: 0.5)
            var y = frame.height - 35
            rows.forEach { row in
                y -= 30
                row.frame = CGRect(x: 25, y: y, width: bounds.width - 35, height: 30)
            }
        }
        
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
}

extension IPerformanceView.ICharts.NSISides.PanelCell.Panel {    
    public func draw(_ value: CPerformance.Chart.V) {
        headline.set(value.type.headline)
        adjust(value)
        load(value)
    }
    
    public func update() {
        separator.backgroundColor = NSColor.box.S1.cgColor
        headline.update()
        rows.forEach { row in
            row.update()
        }
    }
}

extension IPerformanceView.ICharts.NSISides.PanelCell.Panel {
    private func adjust(_ value: CPerformance.Chart.V) {
        let count = value.marks.count + 1 - rows.count
        guard count > 0 else { return }
        (rows.count ..< value.marks.count + 1).forEach { i in
            let row = NoteRow()
            rows.append(row)
            add(row)
        }
        rows[0].load(["指标", "值"])
    }
        
    private func load(_ value: CPerformance.Chart.V) {
        (1 ..< rows.count).forEach { i in
            let row = rows[i]
            row.isHidden = (i - 1) >= value.marks.count
            if row.isHidden.counter {
                row.load(value.marks[i - 1])
            }
        }
    }
}
