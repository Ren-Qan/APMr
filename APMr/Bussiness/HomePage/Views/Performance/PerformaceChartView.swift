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
    
    // MARK: - Private -
    @State private var mouseState = MouseState.none
    
    private enum MouseState {
        case none
        case drag(CGPoint, CGSize)
        case hover(CGPoint)
        case tap(CGPoint)
    }
        
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                ZStack {
                    VStack(spacing: 10) {
                        ForEach(instruments.pCM.models) { chartModel in
                            if chartModel.visiable {
                                chart(chartModel)
                            }
                        }
                    }
                    .padding(.top, 7)
                                        
                    if let location = hoverPoint {
                        GeometryReader { inProxy in
                            Rectangle()
                                .fill(.red)
                                .frame(width: 1, height: proxy.size.height)
                                .position(x: location.x,
                                          y: -inProxy.frame(in: .global).minY + proxy.size.height / 2 + proxy.frame(in: .global).minY)
                        }
                    }
                }
                .onTapGesture{ value in
                    mouseState = .tap(value)
                    service.isShowPerformanceSummary = true
                    updateSummaryRegion(Int(value.x), 1)
                }
                .gesture(
                    DragGesture()
                        .onChanged({ value in
                            let dragStartPoint = value.startLocation
                            var dragSize = value.translation
                            if dragStartPoint.x + dragSize.width > proxy.size.width {
                                dragSize.width = proxy.size.width - dragStartPoint.x
                            }
                            
                            if dragStartPoint.x + dragSize.width < 0 {
                                dragSize.width = -dragStartPoint.x
                            }
                            
                            mouseState = .drag(dragStartPoint, dragSize)
                        })
                        .onEnded({ value in
                            mouseState = .none
                            service.isShowPerformanceSummary = true
                            
                            let x = value.startLocation.x
                            var w = value.translation.width
                            if x + w > proxy.size.width {
                                w = proxy.size.width - x
                            }
                            updateSummaryRegion(Int(x), Int(w))
                        })
                )
            }
            .overlay {
                if let dragValue = dragValue {
                    Rectangle()
                        .fill(.red)
                        .opacity(0.3)
                        .frame(width: abs(dragValue.size.width), height: proxy.size.height)
                        .position(x: dragValue.location.x + dragValue.size.width / 2, y: proxy.size.height / 2)
                }
                
            }
            .onContinuousHover { phase in
                switch phase {
                    case.active(let location):
                        mouseState = .hover(location)
                    case.ended:
                        mouseState = .none
                }
            }
        }
    }
    
    private var hoverPoint: CGPoint? {
        switch mouseState {
            case .hover(let p):
                return p
            default:
                return nil
        }
    }
    
    private var dragValue: (location: CGPoint, size: CGSize)? {
        switch mouseState {
            case .drag(let p, let s):
                return (p, s)
            default:
                return nil
        }
    }
    
    private func updateSummaryRegion(_ x: Int, _ len: Int) {
        var _x = x
        var _len = len
        
        if len < 0 {
            _x += _len
            _len = -len
        }
        
        if _x < 5 {
            _x = 5
        }
    }
}

extension PerformaceChartView {
    private func chart(_ chartModel: ChartModel) -> some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .leading) {
                GroupBox {
                    Text(chartModel.title)
                }
                
                HStack {
                    ForEach(chartModel.series) { series in
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
                ForEach(chartModel.series) { series in
                    ForEach(series.landmarks) { landmark in
                        LineMark(x: .value("time", landmark.x),
                                 y: .value("value", landmark.y),
                                 series: .value("series", series.value))
                        .foregroundStyle(series.style)
                        .interpolationMethod(.cardinal)
                    }
                }
            }
            .offset(x: 10)
            .padding(.vertical, 10)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    if let rawValue = value.as(Int.self), rawValue == 0 {
                        AxisGridLine()
                    }
                    AxisValueLabel()
                }
            }
        }
        .background {
            Color.fabulaBack2
        }
        .padding(.bottom, 10)
    }
}
