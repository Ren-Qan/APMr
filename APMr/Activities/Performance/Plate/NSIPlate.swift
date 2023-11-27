//
//  NSIPlate.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/14.
//

import AppKit

extension IPerformanceView {
    class NSIPlate: NSView {
        public var target: IPlate? = nil
        
        fileprivate lazy var coreHub = CoreHub()
        fileprivate lazy var chooseButton = ChooseButton()
        fileprivate lazy var separator = Separator()
        fileprivate lazy var visibleMenu = ChartsVisibleMenu()
        
        #if DEBUG
        fileprivate(set) lazy var debug_CoreHub = CoreHub()
        #endif
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            
            separator.addTo(self.layer!)
            chooseButton.addTo(self)
            coreHub.addTo(self)
            
            event()
        }
        
        override func layout() {
            coreHub.iLayout.make(bounds) { maker in
                maker.left(10).bottom(10).top(10).width(105)
            }
            
            chooseButton.iLayout.make(bounds) { maker in
                maker.top(10).bottom(10).left(125).width(90)
            }
            
            separator.iLayout.make(bounds) { maker in
                maker.bottom(0).right(0).left(0).height(0.5)
            }
            
            #if DEBUG
            debug_CoreHub.iLayout.make(bounds) { maker in
                maker.left(300).width(105).top(10).bottom(10)
            }
            #endif
        }
        
        override func updateLayer() {
            layer?.backgroundColor = NSColor.box.BG2.cgColor
            separator.backgroundColor = NSColor.box.S1.cgColor
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension IPerformanceView.NSIPlate {
    public func refresh() {
        if let group = target?.performance.chart.group {
            self.visibleMenu.setup(group)
        }
    }
}
    
extension IPerformanceView.NSIPlate {
    fileprivate func event() {
        chooseButton.eventView.mouse(.click) { [weak self] targtet in
            self?.visibleMenu
                .popUp(positioning: nil,
                       at: .init(x: (80 - (self?.visibleMenu.size.width ?? 0)) / 2, y: -10),
                       in: targtet.view)
        }
        
        
        visibleMenu.click = { [weak self] notifier in

        }
        
        #if DEBUG
        debug_CoreHub.addTo(self).eventView.mouse(.click) { [weak self] event in
            self?.debug_CoreHub.isSelected.toggle()
            self?.target?.performance.Debug_sample()
            if let state = self?.target?.performance.isInSample {
                self?.debug_CoreHub.title.string = state ? "stop" : "start"
                self?.debug_CoreHub.layout()
            }
            
        }
        #endif
    }
}

extension IPerformanceView.NSIPlate {
    fileprivate class Separator: CALayer { }
}


extension IPerformanceView.NSIPlate {
    fileprivate class CellButton: NSView {
        fileprivate lazy var eventView = NSIEventView().addTo(self)
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wants(true).background(.random)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            eventView.frame = bounds
        }
    }
}

