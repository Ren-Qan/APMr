//
//  Actor+Displayer.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/31.
//

import AppKit
import Combine

extension CPerformance.Chart.Actor {
    class Displayer {
        fileprivate(set) var mutate = Mutate()
                
        public func reset() {
            mutate = Mutate()
        }
        
        public func sync(closure: (Mutate) -> Mutate) {
            let value = closure(self.mutate)
            sync(value)
        }
        
        public func sync(_ value: Mutate) {
            self.mutate = value
        }
    }
}

extension CPerformance.Chart.Actor.Displayer {
    struct Mutate {
        var offsetX: CGFloat = 0
        var state: State = .latest
    }
    
    enum State {
        case latest
        case stable
    }
}
