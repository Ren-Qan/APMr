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
        
        fileprivate lazy var listButton = ListButton()
        fileprivate lazy var separator = Separator()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            
            layer?.add(separator)
            add(listButton)
            
            event()
        }
        
        override func layout() {
            listButton.iLayout.make(bounds) { maker in
                maker.top(10).bottom(10).width(80).left(10)
            }
            
            separator.iLayout.make(bounds) { maker in
                maker.bottom(0).right(0).left(0).height(0.5)
            }
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
    fileprivate func event() {
        listButton.eventView.mouse(.click) { [weak self] view in

        }
    }
}

extension IPerformanceView.NSIPlate {
    fileprivate class Separator: CALayer { }
    
    fileprivate class ListButton: NSView {
        fileprivate lazy var eventView = NSIEventView()
        fileprivate lazy var highlight = CALayer().alpha(0)
        fileprivate lazy var normal = CALayer()
    
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.adds([normal, highlight])
            add(eventView)

            eventView
                .mouse(.down) { [weak self] button in
                    self?.highlight.opacity = 1
                }
                .mouse(.up) { [weak self] button in
                    self?.highlight.opacity = 0
                }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            eventView.frame = bounds
            highlight.frame = bounds
            normal.frame = bounds
        }
        
        override func updateLayer() {
            highlight.background(.random)
            normal.background(.random)
        }
    }
}

extension IPerformanceView.NSIPlate.ListButton {
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
