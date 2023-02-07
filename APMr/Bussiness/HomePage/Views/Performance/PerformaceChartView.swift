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
                }
                
            }
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
