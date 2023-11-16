//
//  NSIPlate+Choose.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/16.
//

import AppKit

extension IPerformanceView.NSIPlate {
    class ChooseButton: NSView {
        fileprivate(set) lazy var eventView = NSIEventView()
        fileprivate lazy var textLayer = CATextLayer()
        fileprivate lazy var highlight = CALayer()
        fileprivate lazy var normal = CALayer()

        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            
            normal.addTo(self.layer!)
            
            highlight
                .addTo(self.layer!)
                .alpha(0)
            
            textLayer.common
                .addTo(self.layer!)
                .font(13, .current.medium(13))
                .text("选择指标")
            
            eventView
                .addTo(self)
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
            textLayer.fitSize().iLayout.make(bounds) { maker in
                maker.centerH(0).centerV(0)
            }
        }
        
        override func updateLayer() {
            highlight.background(.random)
            normal.background(.random)
            textLayer.foregroundColor = NSColor.orange.cgColor
        }
    }
}


