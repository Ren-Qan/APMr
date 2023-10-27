//
//  IDetailSideView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/11.
//

import SwiftUI

extension IPerformanceView.ICharts {
    struct ISides: NSViewRepresentable {
        var group: CPerformance.Chart.Group
        
        @EnvironmentObject var highlighter: CPerformance.Chart.Highlighter
        
        typealias NSViewType = IPerformanceView.ICharts.NSISides
        
        func makeNSView(context: Context) -> NSViewType {
            let nsView = NSViewType()
            setup(nsView)
            return nsView
        }
        
        func updateNSView(_ nsView: NSViewType, context: Context) {
            setup(nsView)
        }
        
        private func setup(_ nsView: NSViewType) {
            nsView.target = self
            nsView.count = highlighter.snaps.count
            nsView.refresh()
        }
    }
}
