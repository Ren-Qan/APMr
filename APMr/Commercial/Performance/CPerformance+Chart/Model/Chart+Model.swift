//
//  Chart+Model.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/12.
//

import AppKit

extension CPerformance.Chart {
    struct Mark {
        let timing: TimeInterval
        let source: DSPMetrics.M.R
        let label: String
        
        init( _ timing: TimeInterval,
              _ source: DSPMetrics.M.R,
              _ label: String) {
            self.timing = timing
            self.source = source
            self.label = label
        }
    }
}

extension CPerformance.Chart.Actor.Highlighter.Snap {
    class Shot: Identifiable, ObservableObject {
        private(set) var isExpand: Bool = false
        public let index: Int
        
        init(_ index: Int) {
            self.index = index
        }
        
        public func expand(_ value: Bool) {
            if self.isExpand != value {
                objectWillChange.send()
            }
            self.isExpand = value
        }
    }
}