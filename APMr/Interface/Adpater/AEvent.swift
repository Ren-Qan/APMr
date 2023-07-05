//
//  AEvent.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import AppKit
import Combine

class AEvent: ObservableObject {
    var state: S = .invalid
    
    var point: CGPoint = .zero
    var type: String = ""
    
    func sync(_ event: IEventHandleView.IEvent) {
        if event.source.type == .scrollWheel {
            var p = point
            p.x += event.source.deltaX
            p.y += event.source.deltaY
            point = p
        } else {
            point = event.locationInView
        }
        type = "\(event.source.type.rawValue)"
        objectWillChange.send()
    }
}

extension AEvent {
    enum S {
        case invalid
    }
}
