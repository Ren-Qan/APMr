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
        ScrollView {
            VStack(spacing: 10) {
                ForEach(instruments.pCM.models) { chartModel in
                    Chart()
                        .environmentObject(chartModel)
                }
            }
            .padding(.top, 7)
        }
    }
}

private struct Chart: View {    
    @EnvironmentObject var model: ChartModel
        
    var body: some View {
        if model.visiable {
            VStack(alignment: .leading) {
                GroupBox {
                    Text(model.title)
                }
                .offset(x: 10)
                .padding(.top, 5)
                                
                LineChart()
                    .environmentObject(model)
                    .frame(height: 170)
            }
            .background {
                Color.fabulaBack2
            }
            .padding(.bottom, 10)
        }
    }
}
