//
//  Chart+Notifier.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/31.
//

import AppKit
import Combine

extension CPerformance.Chart.Drawer {
    class Notifier: Identifiable, ObservableObject {
        public let type: DSPMetrics.T
        public let graph = Graph()
        
        init(type: DSPMetrics.T) {
            self.type = type
        }
    }
}
