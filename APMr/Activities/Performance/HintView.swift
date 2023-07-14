//
//  HintView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import SwiftUI

extension IPerformanceView {
    struct HintView: NSViewRepresentable {
        @EnvironmentObject var hint: CPerformance.Hint
        
        func makeNSView(context: Context) -> IPerformanceView.NSHintView {
            let view = NSHintView()
            view.target = self
            return view
        }
        
        func updateNSView(_ nsView: IPerformanceView.NSHintView, context: Context) {
            nsView.target = self
            nsView.refresh()
        }
    }
}

extension IPerformanceView {
    class NSHintView: NSView {
        fileprivate var target: HintView? = nil
        
        private lazy var tracker = Element()
        private lazy var selecter = Element()
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            
            selecter.backgroundColor = NSColor.blue.withAlphaComponent(0.2).cgColor
            tracker.backgroundColor = NSColor.red.withAlphaComponent(0.2).cgColor
            
            layer?.addSublayer(selecter)
            layer?.addSublayer(tracker)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layout() {
            if bounds.size.width != 0, bounds.size.height != 0 {
                refresh()
            }
        }
        
        func refresh() {
            drawTracker()
            drawSelecter()
        }
        
        private func drawTracker() {
            guard let hintter = target?.hint else {
                tracker.opacity = 0
                return
            }
            
            switch hintter.move {
                case .empty:
                    tracker.opacity = 0
                    return
                    
                case .move(let location):
                    tracker.opacity = 1
                    tracker.frame = .init(x: location.x - 1, y: 0, width: 2, height: bounds.height)
            }
        }
        
        private func drawSelecter() {
            guard let hintter = target?.hint else {
                selecter.opacity = 0
                return
            }
            
            var rect: CGRect = .zero
            
            switch hintter.select {
                case .empty:
                    selecter.opacity = 0
                    return
                    
                case .drag(let area):
                    selecter.opacity = 1
                    rect = .init(x: area.origin.x, y: 0, width: area.size.width, height: bounds.height)
                    
                case .click(let point):
                    selecter.opacity = 1
                    rect = .init(x: point.x - 1, y: 0, width: 2, height: bounds.height)
            }
            
            selecter.frame = rect
        }
    }
}

