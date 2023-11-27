//
//  NSIPlate+ControlCenter.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/20.
//

import AppKit

extension IPerformanceView.NSIPlate {
    class CoreHub: NSView {
        public var isSelected = false {
            didSet {
                selectedLayer.alpha(isSelected ? 1 : 0)
            }
        }
        
        fileprivate lazy var highlightLayer = CALayer().alpha(0)
        fileprivate lazy var selectedLayer = CALayer().alpha(0)
        
        fileprivate(set) lazy var icon = NSImageView()
        fileprivate(set) lazy var title = CATextLayer().common
        fileprivate(set) lazy var eventView = NSIEventView().highlight { [weak self] event in
            self?.highlightLayer.alpha(event.isHighligt ? 1 : 0)
        }
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            
            icon.addTo(self)
            eventView.addTo(self)
            
            selectedLayer.addTo(self.layer!)
            highlightLayer.addTo(self.layer!)
            
            title.font(13.5, .current.medium(13.5))
                .addTo(self.layer!)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            eventView.frame = bounds
            selectedLayer.frame = bounds
            highlightLayer.frame = bounds
                        
            title.iFit().iLayout.make(bounds) { maker in
                maker.centerH(8.5).centerV(0)
            }
            
            icon.iLayout.make(bounds) { maker in
                maker.width(15).height(15).centerH(-(title.bounds.width / 2 + 1)).centerV(0)
            }
        }
        
        override func updateLayer() {
            background(.box.SBG1)
            title.color(.box.H1)
            
            selectedLayer.background(.red)
            highlightLayer.background(.orange)
            icon.background(.random)
        }    
    }
}
