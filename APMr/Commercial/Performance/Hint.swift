//
//  Hint.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/18.
//

import AppKit
import Combine

extension CPerformance {
    class Hint: ObservableObject {
        private var current: State = .stop
        private(set) var scrollX: CGFloat = 0
        
        private var dragRect: CGRect = .zero
        private(set) var interactive: I = .empty
        
        func sync(_ iEvent: IEventHandleView.IEvent) {
            guard iEvent.isInTarget else {
                return
            }
            
            if iEvent.source.type == .scrollWheel, iEvent.source.hasPreciseScrollingDeltas {
                scroll(iEvent)
            }
            
            if iEvent.source.type == .leftMouseDown {
                dragRect.origin = iEvent.locationInTarget
                dragRect.size.width = 0
                interactive = .begin
                objectWillChange.send()
            } else if iEvent.source.type == .leftMouseDragged || (iEvent.source.type == .leftMouseUp && iEvent.source.clickCount == 0) {
                dragRect.size.width += iEvent.source.deltaX
                interactive = .drag(dragRect)
                objectWillChange.send()
            } else if iEvent.source.type == .leftMouseUp, iEvent.source.clickCount == 1 {
                interactive = .click(iEvent.locationInTarget)
                objectWillChange.send()
            } 
        }
        
        private func scroll(_ iEvent: IEventHandleView.IEvent) {
            let dx = iEvent.source.scrollingDeltaX
            let dy = iEvent.source.scrollingDeltaY
            
            if dx == 0, dy == 0 {
                current = .stop
                scrollX = 0
                return
            }
            
            if current == .stop {
                if dx != 0, dy == 0 {
                    current = .scrollH
                } else {
                    current = .scrollV
                }
            }
            
            if current == .scrollH {
                scrollX = dx
                objectWillChange.send()
            } else {
                scrollX = 0
            }
        }
    }
}

extension CPerformance.Hint {
    fileprivate enum State {
        case scrollH
        case scrollV
        case stop
    }
    
    enum I {
        case empty
        case begin
        case click(CGPoint)
        case drag(CGRect)
    }
}
