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
        
        fileprivate lazy var listButton = ListButton().wants(true)
        fileprivate lazy var separator = Separator()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            
            layer?.add(separator)
            
            listButton.addTo(self)
        }
        
        override func layout() {
            listButton.frame = .init(x: 10, y: 8, width: 80, height: bounds.size.height - 16)
            separator.frame = .init(x: 0, y: 0, width: bounds.width, height: 0.5)
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
        
    }
}

extension IPerformanceView.NSIPlate {
    fileprivate class Separator: CALayer {
        
    }
    
    fileprivate class BGLayer: CALayer {
        
    }
    
    fileprivate class ListButton: NSView {
        fileprivate lazy var highlight = BGLayer()
        
        fileprivate lazy var normal = BGLayer()
        
        fileprivate lazy var eventView = NSIEventView()

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            add(eventView)
            layer?.adds([normal, highlight])
            
            highlight.opacity = 0
            eventView
                .mouse(.down) { [weak self] button in
                    self?.highlight.opacity = 1
                }
                .mouse(.up) { [weak self] button in
                    self?.highlight.opacity = 0
                }
                .mouse(.entered) { button in
                    
                }
                .mouse(.existed) { button in
                    
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
            highlight.backgroundColor = NSColor.black.withAlphaComponent(0.3).cgColor
            normal.backgroundColor = NSColor.box.GREEN1.cgColor
        }
    }
}
