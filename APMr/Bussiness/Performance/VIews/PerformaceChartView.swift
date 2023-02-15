//
//  PerformaceChartView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/17.
//

import SwiftUI
import Charts


struct PerformaceChartView: View {
    // MARK: - Public 
    @EnvironmentObject var service: HomepageService
    
    @EnvironmentObject var instruments: PerformanceInstrumentsService
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                ZStack {
                    VStack(spacing: 10) {
                        ForEach(instruments.pCM.models) { chartModel in
                            LineChartGroup()
                                .environmentObject(service)
                                .environmentObject(chartModel)
                                .environmentObject(instruments)
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
        @EnvironmentObject var service: HomepageService
        @EnvironmentObject var instruments: PerformanceInstrumentsService
        @EnvironmentObject var model: ChartModel
        
        var body: some View {
            if model.visiable {
                VStack(alignment: .leading) {
                    ZStack(alignment: .leading) {
                        GroupBox {
                            Text(model.type.name)
                        }
                        
                        HStack {
                            ForEach(model.series) { series in
                                HStack {
                                    Rectangle()
                                        .fill(series.style)
                                        .frame(width: 9, height: 2)
                                    Text(series.value)
                                }
                                .onTapGesture {
                                    series.visiable.toggle()
                                    model.objectWillChange.send()
                                }
                            }
                        }
                        .padding(.leading, 120)
                    }
                    .offset(x: 10)
                    .padding(.top, 5)
                    
                    Chart {
                        ForEach(model.chartShowSeries) { series in
                            ForEach(series.chartLandMarks(axis: model.xAxis)) { landmark in
                                LineMark(x: .value("time", landmark.x),
                                         y: .value("value", landmark.y),
                                         series: .value("series", series.value))
                                .foregroundStyle(series.style)
                                .interpolationMethod(.cardinal)
                            }
                        }
                    }
                    .animation(.default, value: true)
                    .chartXScale(domain: model.xAxis.start ... model.xAxis.end)
                    .chartYScale(domain: model.yAxis.start ... model.yAxis.end)
                    .padding(.trailing, 20)
                    .padding(.vertical, 10)
                    .chartXAxis {
                        AxisMarks(values: .automatic(desiredCount: model.xAxis.len)) { value in
                            if let rawValue = value.as(Int.self) {
                                if rawValue == model.xAxis.start {
                                    AxisGridLine(stroke: .init(lineWidth: 1))
                                }
                                
                                if rawValue != 0,
                                   (rawValue - model.xAxis.start) % 10 == 0 {
                                    AxisValueLabel {
                                        Text("\(rawValue)")
                                    }
                                    AxisTick(stroke: .init(lineWidth: 1))
                                }
                            }
                        }
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            if let rawValue = value.as(Int.self) {
                                if rawValue == model.yAxis.start {
                                    AxisGridLine()
                                    AxisTick(stroke: .init(lineWidth: 1))
                                }
                                AxisValueLabel {
                                    Text("\(rawValue)")
                                        .frame(width: 40, alignment: .trailing)
                                }
                            }
                        }
                    }
                    .chartOverlay { proxy in
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(.clear)
                                .contentShape(Rectangle())
                                .gesture(
                                    SpatialTapGesture()
                                        .onEnded { value in
                                            findElement(value.location,
                                                        .zero,
                                                        proxy,
                                                        geometry)
                                        }
                                        .exclusively(
                                            before: DragGesture()
                                                .onChanged { value in
                                                    findElement(value.startLocation,
                                                                value.location,
                                                                proxy,
                                                                geometry,
                                                                true)
                                                }
                                        )
                                )
                        }
                            
                    }
                }
                .background {
                    Color.fabulaBack2
                }
                .padding(.bottom, 10)
            }
        }
        
        private func findElement(_ location: CGPoint,
                                 _ endLocation: CGPoint,
                                 _ proxy: ChartProxy,
                                 _ geometry: GeometryProxy,
                                 _ isDraging: Bool = false) {
            let offsetX = geometry[proxy.plotAreaFrame].origin.x
            let locationX = location.x - offsetX
            guard let startX: Int = proxy.value(atX: locationX) else {
                return
            }
            
            let s = startX
            var e = 0
            
            if isDraging {
                guard let endX: Int = proxy.value(atX: endLocation.x - offsetX) else {
                    return
                }
                e = endX
            }
            if !service.isShowPerformanceSummary {
                service.isShowPerformanceSummary = true
            }
            instruments.highlight(start: s, end: e, isDragging: isDraging)
        }
    }	
}
