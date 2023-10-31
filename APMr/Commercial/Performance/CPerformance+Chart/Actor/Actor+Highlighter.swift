//
//  Actor+Highlighter.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/31.
//

import AppKit
import Combine

extension CPerformance.Chart.Actor {
    class Highlighter {
        fileprivate(set) var current: Hint.Action = .none
        fileprivate(set) var hint = Hint()
        
        fileprivate(set) var snap = Snap()
        
        public func reset() {
            current = .none
            hint = Hint()
            snap.reset()
        }
    }
}

extension CPerformance.Chart.Actor.Highlighter {
    public func update(_ value: Hint.Action) {
        self.current = value
    }
    
    public func sync(closure: (Hint) -> Hint) {
        let hint = closure(self.hint)
        sync(hint)
    }
    
    public func sync(_ hint: Hint) {
        self.hint = hint
        self.snap.check(hint)
    }
}

extension CPerformance.Chart.Actor.Highlighter {
    struct Hint {
        var action: Action = .none
        var begin: C? = nil
        var end: C? = nil
        
        func equal(_ value: Hint) -> Bool {
            if action == value.action {
                func e(_ l: C?, _ r: C?) -> Bool {
                    if l == nil, r == nil {
                        return true
                    }
                    
                    if let l, let r, l.offset == r.offset, l.location.x == r.location.x {
                        return true
                    }
                    
                    return false
                }
                
                return e(begin, value.begin) && e(end, value.end)
            }
            return false
        }
    }
}

extension CPerformance.Chart.Actor.Highlighter.Hint {
    enum Action {
        case none
        case click
        case drag
    }
    
    struct C {
        var offset: CGFloat = 0
        var location: CGPoint = .zero
    }
}
