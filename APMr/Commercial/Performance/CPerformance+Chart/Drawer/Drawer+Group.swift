//
//  Chart+Group.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/31.
//

import AppKit
import Combine

extension CPerformance.Chart.Drawer {
    class Group: ObservableObject {
        public var inset: NSEdgeInsets { CPerformance.Chart.inset }
        public var width: CGFloat { CPerformance.Chart.width }
        
        fileprivate(set) var snapCount: Int = 0
        fileprivate(set) var notifiers: [Notifier] = []
        
        public func reset() {
            snapCount = 0
            notifiers.forEach { notifier in
                notifier.graph.clean()
            }
        }
        
        public func sync() {
            self.snapCount += 1
            self.objectWillChange.send()
        }
        
        public func add(_ notifier: Notifier) {
            notifiers.append(notifier)
        }
    }
}
