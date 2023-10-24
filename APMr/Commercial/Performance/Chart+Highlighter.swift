//
//  Chart+Highlighter.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/16.
//

import Foundation

extension CPerformance.Chart {
    class Highlighter: ObservableObject {
        fileprivate(set) var snaps: [Snap] = []
        private var dataRange: Range<Int>? = nil {
            didSet {
                collectSnap()
            }
        }
        
        private var width: CGFloat = 20
        private var inset = NSEdgeInsets(top: 25, left: 20, bottom: 20, right: 0)
        private var snapCount = 0
        
        public var offsetX: CGFloat = 0
        public var offsetXState: IPerformanceView.NSICharts.S = .latest
        public var hint = IPerformanceView.NSICharts.Hint() {
            didSet {
                check()
            }
        }
    }
}

extension CPerformance.Chart.Highlighter {
    public func reset() {
        offsetX = 0
        offsetXState = .latest
        hint = .init()
        snapCount = 0
        objectWillChange.send()
    }
    
    public func sync(_ inset: NSEdgeInsets,
                     _ width: CGFloat,
                     _ snapCount: Int) {
        var isNeedSend = false
        self.snapCount = snapCount
        
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
            objectWillChange.send()
        }
    }
    
    private var range: Range<Int>? {
        guard snapCount > 0, hint.action != .none else {
            return nil
        }
        
        let c = Int(hint.area.width / width) + 1
        var l = Int((-hint.offsetX + hint.area.origin.x - inset.left) / width)
        var r = l + c
        
        if hint.area.size.width < 0 {
            l -= c
            r -= c
        }
        
        if l < 0 { l = 0 }
        if r >= snapCount { r = snapCount - 1 }
        if l > r { l = r }
        if hint.action == .click { r = l }
        
        return l ..< r + 1
    }
    
    fileprivate func check() {
        let new = range
        if new == nil, dataRange == nil {
            return
        }
        
        guard let new = new,
              let old = dataRange else {
            dataRange = new
            objectWillChange.send()
            return
        }
        
        guard new.lowerBound != old.lowerBound ||
                new.upperBound != old.upperBound else {
            return
        }
        
        self.dataRange = new
        objectWillChange.send()
    }
    
    fileprivate func collectSnap() {
        guard let range else {
            snaps = []
            return
        }
        
        snaps = range.compactMap { index in
            guard index < snapCount else {
                return nil
            }
            return Snap(index)
        }
    }
}

