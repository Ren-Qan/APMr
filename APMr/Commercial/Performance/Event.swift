//
//  AEvent.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import AppKit
import Combine

extension CPerformance {
    class Hint: ObservableObject {
        fileprivate(set) var move: M = .empty
        fileprivate(set) var select: S = .empty
        fileprivate(set) var offset: CGPoint = .zero
        
        private var drag: CGRect = .zero
        private var isNeedUpdateStartLocation = true
        
        public func clean() {
            select = .empty
            offset = .zero
        }
        
        public func sync(_ iEvent: IEventHandleView.IEvent) {
            var needSendObserver = true
            if iEvent.source.type == .mouseExited {
                move = .empty
            } else if iEvent.source.type == .leftMouseDown {
                drag = .zero
                isNeedUpdateStartLocation = true
            } else if iEvent.source.type == .mouseEntered || iEvent.source.type == .mouseMoved {
                move = .move(iEvent.locationInView)
            } else if iEvent.source.type == .leftMouseDragged {
                if isNeedUpdateStartLocation {
                    drag.origin = iEvent.locationInView
                    isNeedUpdateStartLocation = false
                }
                drag.size.width += iEvent.source.deltaX
                select = .drag(drag)
                move = .empty
            } else if iEvent.source.type == .leftMouseUp, iEvent.source.clickCount > 0 {
                select = .click(iEvent.locationInView)
                move = .empty
            } else if iEvent.source.type == .scrollWheel {
                offset.x += iEvent.source.deltaX
            } else {
                needSendObserver = false
            }
            
            if needSendObserver {
                objectWillChange.send()
            }
        }
    }
}

extension CPerformance.Hint {
    enum M {
        case move(CGPoint)
        case empty
    }
    
    enum S {
        case click(CGPoint)
        case drag(CGRect)
        case empty
    }
}
