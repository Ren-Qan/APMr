//
//  AEvent.swift
//  APMr
//
//  Created by 任玉乾 on 2023/7/4.
//

import AppKit
import Combine

class AEvent: ObservableObject {
    @Published var state: S = .invalid
    
    func sync(_ event: NSEvent) {
        
    }
}

extension AEvent {
    enum S {
        case invalid
    }
}
