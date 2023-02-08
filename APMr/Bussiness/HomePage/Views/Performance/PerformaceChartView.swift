//
//  PerformaceChartView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/17.
//

import SwiftUI
import Charts


struct PerformaceChartView: View {
    // MARK: - Public -
    @EnvironmentObject var service: HomepageService
    
    @EnvironmentObject var instruments: HomepageInstrumentsService
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                ZStack {
                    VStack(spacing: 10) {
                        ForEach(instruments.pCM.models) { chartModel in
                            LineChartGroup()
                                .environmentObject(chartModel)
                        }
                    }
                    .padding(.top, 7)
                }
            }
        }
    }
}

extension PerformaceChartView {
    private struct LineChartGroup: View {
        @EnvironmentObject var model: ChartModel
        
        var body: some View {
            if model.visiable {
                VStack(alignment: .leading) {
                    ZStack(alignment: .leading) {
                        GroupBox {
                            Text(model.title)
                        }
                        
                        HStack {
                            ForEach(model.chartShowSeries) { series in
                                Rectangle()
                                    .fill(series.style)
                                    .frame(width: 9, height: 2)
                                Text(series.value)
                            }
                        }
                        .padding(.leading, 120)
                    }
                    .offset(x: 10)
                    .padding(.top, 5)
                    
                    Chart {
                        ForEach(model.series) { series in
                            ForEach(series.chartLandMarks(axis: model.xAxis)) { landmark in
                                LineMark(x: .value("time", landmark.x),
                                         y: .value("value", landmark.y),
                                         series: .value("series", series.value))
                                .foregroundStyle(series.style)
                                .interpolationMethod(.cardinal)
                            }
                        }
                    }
                    .chartXScale(domain: model.xAxis.start ... model.xAxis.end)
                    .chartYScale(domain: model.yAxis.start ... model.yAxis.end)
                    .padding(.trailing, 20)
                    .padding(.vertical, 10)
                    .chartXAxis {
                        AxisMarks { value in
                            if let rawValue = value.as(Int.self) {
                                if rawValue == model.xAxis.start {
                                    AxisGridLine(stroke: .init(lineWidth: 1))
                                } else {
                                    AxisValueLabel {
                                        Text("\(rawValue)")
                                    }
                                    
                                    AxisTick(stroke: .init(lineWidth: 1))
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            if let rawValue = value.as(Int.self) {
                                if rawValue == model.yAxis.start {
                                    AxisGridLine()
                                }
                                AxisValueLabel {
                                    Text("\(rawValue)")
                                        .frame(width: 40, alignment: .trailing)
                                }
                            }
                        }
                    }
                }
                .background {
                    Color.fabulaBack2
                }
                .padding(.bottom, 10)
            }
        }
    }
}
