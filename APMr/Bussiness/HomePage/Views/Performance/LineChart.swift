//
//  LineChart.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/3.
//

import Foundation
import SwiftUI
import Charts

struct LineChart: NSViewRepresentable {
        
    typealias NSViewType = LineChartView
        
    @EnvironmentObject var chartModel: ChartModel
        
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> LineChartView {
        let view = LineChartView()
        view.delegate = context.coordinator
        view.data = chartModel.chartData
        view.doubleTapToZoomEnabled = false
        view.dragYEnabled = false
        view.dragXEnabled = false
        view.scaleYEnabled = false
        view.pinchZoomEnabled = false
        view.scaleXEnabled = true
        
        view.xAxis.labelPosition = .bottom
        view.xAxis.drawGridLinesEnabled = false
        view.xAxis.setLabelCount(10, force: true)
        
        view.legend.horizontalAlignment = .center
        view.legend.verticalAlignment = .top
        
        view.leftAxis.drawTopYLabelEntryEnabled = true
        view.leftAxis.drawGridLinesEnabled = false
        
        view.rightAxis.enabled = false
        view.drawGridBackgroundEnabled = false
        return view
    }
    
    func updateNSView(_ nsView: Charts.LineChartView, context: Context) {
        let count = chartModel.sets[0].entries.count
        
        if count >= 100 {
            nsView.xAxis.axisMinimum = Double(count - 100)
            nsView.xAxis.axisMaximum = Double(count)
        }
        
        nsView.notifyDataSetChanged()
        
        if count > 0 {
            nsView.setVisibleXRange(minXRange: 100, maxXRange: 100)
        }
    }
}

extension LineChart {
    internal class Coordinator: NSObject, ChartViewDelegate {
        func chartValueSelected(_ chartView: ChartViewBase,
                                entry: ChartDataEntry,
                                highlight: Highlight) {
        }
    }
}
