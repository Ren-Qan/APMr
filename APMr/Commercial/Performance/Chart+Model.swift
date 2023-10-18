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
