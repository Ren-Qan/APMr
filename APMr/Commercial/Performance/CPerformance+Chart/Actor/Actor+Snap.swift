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
        
        fileprivate var shots: [Shot] = []
        fileprivate var range: Range<Int>? = nil
        
        fileprivate var width: CGFloat = 20
        fileprivate var inset = NSEdgeInsets(top: 25, left: 20, bottom: 20, right: 0)
    }
}

extension CPerformance.Chart.Actor.Highlighter.Snap {
    public var items: [Shot] {
        guard let range else {
            return []
        }
        return Array(shots[range])
    }
    
    public func reset() {
        shots.removeAll()
        sync(nil)
    }
    
    public func set(_ timing: TimeInterval, _ values: [CPerformance.Chart.V]) {
        let shot = Shot(shots.count, timing, values)
        shots.append(shot)
    }
    
    public func match(_ width: CGFloat,
                      _ inset: NSEdgeInsets) {
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
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    public func check(_ hint: H.Hint) {
        guard shots.count > 0,
              hint.action != .none,
              let begin = hint.begin,
              let end = hint.end else {
            if range != nil {
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
        
        if endX < startX {
            l -= c
            r -= c
        }
        
        if l < 0 { l = 0 }
        if r >= shots.count { r = shots.count - 1 }
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
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
            return
        }
        
        if let range,
           range.upperBound == value.upperBound,
           range.lowerBound == value.lowerBound {
            return
        }
        
        self.range = value
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}
