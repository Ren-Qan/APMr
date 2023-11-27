//
//  NSIPlate+ChartsVisibleMenu.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/16.
//

import AppKit

extension IPerformanceView.NSIPlate {
    class ChartsVisibleMenu: NSMenu {
        private(set) var group: CPerformance.Chart.Drawer.Group? = nil
        
        public var click: ((_ notifer: CPerformance.Chart.Drawer.Notifier) -> Void)? = nil
        
        public func setup(_ group: CPerformance.Chart.Drawer.Group) {
            if self.group === group {
                return
            }
            self.group = group
            adjust(group)
            load(group)
        }
    }
}

extension IPerformanceView.NSIPlate.ChartsVisibleMenu {
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
            item?.contentView.eventView.mouse(.click) { [weak self, weak item] event in
                self?.click?(notifer)
                item?.contentView.refresh()
            }
        }
    }
}

extension IPerformanceView.NSIPlate.ChartsVisibleMenu {
    fileprivate class Item: NSMenuItem {
        fileprivate lazy var contentView = ItemView(frame: CGRect(x: 0, y: 0, width: 200, height: 40)).wants(true)

        fileprivate func setup(_ notifer: CPerformance.Chart.Drawer.Notifier) {
            self.view = contentView
            self.contentView.notifer = notifer
            self.contentView.refresh()
        }
    }
    
    fileprivate class ItemView: NSView {
        var notifer: CPerformance.Chart.Drawer.Notifier? = nil
                
        private lazy var highlight = CALayer()
            .addTo(self.layer!)
            .alpha(0)
            .background(.black.withAlphaComponent(0.3))
        
        fileprivate lazy var eventView = NSIEventView()
            .addTo(self)
            .highlight { [weak self] event in
                self?.highlight.alpha(event.isHighligt ? 1 : 0)
            }
        
        fileprivate lazy var select = NSImageView().wants(true).addTo(self)
        fileprivate lazy var title = CATextLayer().addTo(self.layer!)
        
        override func layout() {
            eventView.frame = bounds
            
            select.iLayout.make(bounds) { maker in
                maker.centerV(0).left(10).width(23).height(23)
            }
    
            highlight.corner(4).iLayout.make(bounds) { maker in
                maker.left(5).right(5).top(5).bottom(5)
            }            
        }
        
        override func updateLayer() {
            title.color(.box.H1)
        }
        
        fileprivate func refresh() {
            guard let notifer else { return }
            
            select.symbol(Bool.random() ? "square" : "checkmark.square.fill")
            
            if let string = title.string as? String,
               string == notifer.type.headline {} else {
                   title.common
                       .text(notifer.type.headline)
                       .font(12, .current.medium(12))
                       .iFit()
                       .iLayout.make(bounds) { maker in
                           maker.centerV(0).left(40)
                       }
               }
        }
    }
}
