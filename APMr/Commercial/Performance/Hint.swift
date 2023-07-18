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
        private(set) var deltaX: CGFloat = 0
        
        func sync(_ iEvent: IEventHandleView.IEvent) {
            if iEvent.source.type == .scrollWheel, iEvent.source.hasPreciseScrollingDeltas {
                scroll(iEvent)
            }
        }
        
        private func scroll(_ iEvent: IEventHandleView.IEvent) {
            let dx = iEvent.source.scrollingDeltaX
            let dy = iEvent.source.scrollingDeltaY
            
            if dx == 0, dy == 0 {
                current = .stop
                deltaX = 0
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
                deltaX = dx
                objectWillChange.send()
            } else {
                deltaX = 0
            }
        }
    }
}

extension CPerformance.Hint {
    enum State {
        case scrollH
        case scrollV
        case stop
    }
}
