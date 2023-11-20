//
//  NSIPlate+ControlCenter.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/20.
//

import AppKit

extension IPerformanceView.NSIPlate {
    class CoreHub: NSView {
        fileprivate lazy var highlightLayer = CALayer().alpha(0)
        fileprivate(set) lazy var eventView = NSIEventView().highlight { [weak self] event in
            self?.highlightLayer.alpha(event.isHighligt ? 1 : 0)
        }
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            eventView.addTo(self)
            
            
            
            
            highlightLayer.addTo(self.layer!)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            eventView.frame = bounds
            highlightLayer.frame = bounds
        }
        
        override func updateLayer() {
            background(.random)
            highlightLayer.background(.orange)
        }
    }
}
