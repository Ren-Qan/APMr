//
//  Chart+Model.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/12.
//

import AppKit

extension CPerformance.Chart {
    struct Mark {
        let source: DSPMetrics.M.R
        let label: String
        
        init(_ source: DSPMetrics.M.R,
             _ label: String) {
            self.source = source
            self.label = label
        }
    }
}
