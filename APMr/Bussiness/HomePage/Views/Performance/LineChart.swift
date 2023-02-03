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
    
    func makeNSView(context: Context) -> LineChartView {
        let view = LineChartView()
        return view
    }
    
    func updateNSView(_ nsView: Charts.LineChartView, context: Context) {
        let set = LineChartDataSet()
        set.drawCirclesEnabled = false
        set.mode = .cubicBezier
        set.drawHorizontalHighlightIndicatorEnabled = true
        set.colors = [.brown, .red]
        set.highlightColor = .white
        set.highlightLineDashLengths = [1, 2]
        
        (0 ..< 1000).forEach { i in
            set.append(.init(x: Double(i), y: .random(in: 0 ... 100)))
        }
        
        let chartData = LineChartData(dataSet: set)
        
        nsView.data = chartData
        nsView.pinchZoomEnabled = false
        nsView.doubleTapToZoomEnabled = false
                
        nsView.setVisibleXRange(minXRange: 100, maxXRange: 100)
        nsView.minOffset = 20
        
        nsView.xAxis.labelPosition = .bottom
        nsView.xAxis.drawGridLinesEnabled = false
        
        nsView.leftAxis.drawTopYLabelEntryEnabled = true
        nsView.leftAxis.drawGridLinesEnabled = false
        
        nsView.rightAxis.enabled = false
        nsView.drawGridBackgroundEnabled = false
        nsView.viewPortHandler.setChartDimens(width: 10, height: 10)
    }
}
