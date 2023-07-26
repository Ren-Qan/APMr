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
        
        private(set) var active: Active? = nil
        
        public func sync(_ iEvent: IEventHandleView.IEvent) {
            guard iEvent.isInTarget else {
                return
            }
            
            if iEvent.source.type == .scrollWheel, iEvent.source.hasPreciseScrollingDeltas {
                scroll(iEvent)
            }
            
            if iEvent.source.type == .leftMouseDown {
                active = .init(state: .began, type: .begin, value: .init(origin: iEvent.locationInTarget, size: .zero))
                objectWillChange.send()
            } else if iEvent.source.type == .leftMouseDragged || (iEvent.source.type == .leftMouseUp && iEvent.source.clickCount == 0) {
                var value = active?.value ?? .zero
                value.size.width += iEvent.source.deltaX
                active = .init(state: iEvent.source.type == .leftMouseDragged ? .changed : .ended, type: .drag, value: value)
                objectWillChange.send()
            } else if iEvent.source.type == .leftMouseUp, iEvent.source.clickCount == 1 {
                active = .init(state: .ended, type: .click, value: .init(origin: iEvent.locationInTarget, size: .zero))
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
    
    struct Active {
        enum T {
            case begin
            case click
            case drag
        }
        
        let state: NSGestureRecognizer.State
        let type: T
        let value: CGRect
    }
}
