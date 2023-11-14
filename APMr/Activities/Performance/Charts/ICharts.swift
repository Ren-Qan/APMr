//
//  ITableView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/8/10.
//

import AppKit
import SwiftUI

extension IPerformanceView {
    struct ICharts: NSViewRepresentable {
        @EnvironmentObject var group: CPerformance.Chart.Drawer.Group
        @EnvironmentObject var actor: CPerformance.Chart.Actor
        
        func makeNSView(context: Context) -> IPerformanceView.NSICharts {
            let nsView = IPerformanceView.NSICharts()
            setup(nsView)
            return nsView
        }
        
        func updateNSView(_ nsView: IPerformanceView.NSICharts, context: Context) {
            setup(nsView)
        }
        
        private func setup(_ nsView: IPerformanceView.NSICharts) {
            nsView.target = self
            nsView.refresh()
        }
    }
}

