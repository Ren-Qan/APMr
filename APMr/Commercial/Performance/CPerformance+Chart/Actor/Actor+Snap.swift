//
//  Highlighter+Snaper.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/31.
//

import AppKit
import Combine

extension CPerformance.Chart.Actor.Highlighter {
    class Snap: ObservableObject {
        typealias H = CPerformance.Chart.Actor.Highlighter
        
        fileprivate(set) var shots: [Shot] = []
        fileprivate var range: Range<Int>? = nil
        
        fileprivate var width: CGFloat = 20
        fileprivate var inset = NSEdgeInsets(top: 25, left: 20, bottom: 20, right: 0)
        fileprivate var ceil = 0
    }
}

extension CPerformance.Chart.Actor.Highlighter.Snap {
    public func reset() {
        guard range != nil else {
             return
        }
        range = nil
        shots = []
        objectWillChange.send()
    }
    
    public func match(_ width: CGFloat, _ inset: NSEdgeInsets, _ ceil: Int) {
        self.ceil = ceil
        var isNeedSend = false

        if self.width != width {
            self.width = width
            isNeedSend = true
        }

        if self.inset.top != inset.top ||
           self.inset.bottom != inset.bottom ||
           self.inset.left != inset.left ||
           self.inset.right != inset.right {
            self.inset = inset
            isNeedSend = true
        }

        if isNeedSend {
            sync(nil)
            objectWillChange.send()
        }
    }
    
    public func check(_ hint: H.Hint) {
        guard ceil > 0, hint.action != .none, let begin = hint.begin, let end = hint.end else {
            if shots.count > 0 {
                sync(nil)
            }
            return
        }
        
        let startX = begin.location.x - inset.left - begin.offset
        let endX = end.location.x - inset.left - end.offset
        let w = abs(endX - startX)
        
        let c = Int(w / width) + 1
        var l = Int(startX / width)
        var r = l + c
        
        print("All:\(c) L:\(l) R:\(r)")
        
        if endX < startX {
            l -= c
            r -= c
        }
        
        if l < 0 { l = 0 }
        if r >= ceil { r = ceil - 1 }
        if l > r { l = r }
        if hint.action == .click { r = l }
        self.sync(l ..< r + 1)
    }
}

extension CPerformance.Chart.Actor.Highlighter.Snap {
    fileprivate func sync(_ value: Range<Int>?) {
        guard let value else {
            if self.range != nil {
                self.range = nil
                self.shots = []
                objectWillChange.send()
            }
            return
        }
        
        if let range,
           range.upperBound == value.upperBound,
           range.lowerBound == value.lowerBound {
            return
        }
        
        self.range = value
        self.shots = value.compactMap { index in
            guard index < ceil else { return nil }
            return Shot(index)
        }
        objectWillChange.send()
    }
}
