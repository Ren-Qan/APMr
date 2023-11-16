//
//  NSIPlate+ChartVisibleMenu.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/16.
//

import AppKit

extension IPerformanceView.NSIPlate {
    class ChartVisibleMenu: NSMenu {
        
    }
}

extension IPerformanceView.NSIPlate.ChartVisibleMenu {
    public func setup(_ group: CPerformance.Chart.Drawer.Group) {
        adjust(group)
        load(group)
    }
    
    private func adjust(_ group: CPerformance.Chart.Drawer.Group) {
        let count = group.notifiers.count - items.count
        if count == 0 {
            return
        }
        
        if count > 0 {
            (items.count ..< group.notifiers.count).forEach { i in
                let item = Item()
                item.tag = i
                addItem(item)
            }
        }
        
        if count < 0 {
            (group.notifiers.count ..< items.count).forEach { i in
                removeItem(at: i)
            }
        }
    }
    
    private func load(_ group: CPerformance.Chart.Drawer.Group) {
        (0 ..< group.notifiers.count).forEach { i in
            let item = items[i] as? Item
            let notifer = group.notifiers[i]
            item?.setup(notifer)
        }
    }
}

extension IPerformanceView.NSIPlate.ChartVisibleMenu {
    fileprivate class Item: NSMenuItem {
        lazy var contentView = ItemView(frame: CGRect(x: 0, y: 0, width: 200, height: 40)).wants(true)

        fileprivate func setup(_ notifer: CPerformance.Chart.Drawer.Notifier) {
            self.view = contentView
            self.contentView.target = notifer
            self.contentView.eventView.mouse(.moved) { view in
                print("[\(self.tag)] ===== \(Int.random(in: 0 ..< 1000))")
            }
        }
    }
    
    fileprivate class ItemView: NSView {
        var target: CPerformance.Chart.Drawer.Notifier? = nil {
            didSet {
                refresh()
            }
        }
        
        private lazy var bgLayer = CALayer()
            .addTo(self.layer!)
            .alpha(0)
            .background(.black.withAlphaComponent(0.3))
        
        lazy var eventView = NSIEventView()
            .addTo(self)
            .highlight { [weak self] highlight, event in
                self?.bgLayer.alpha(highlight ? 1 : 0)
            }

        override func layout() {
            eventView.frame = bounds
            bgLayer.iLayout.make(bounds) { maker in
                maker.left(5).right(5).top(0).bottom(0)
            }
        }
        
        func refresh() {
            
        }
    }
}
