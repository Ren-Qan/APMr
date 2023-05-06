//
//  PerformanceView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/10.
//

import SwiftUI

struct PerformanceView: View {
    
    @EnvironmentObject var deviceService: DeviceService
    
    @EnvironmentObject var performance: PerformanceInstrumentsService
    
    var body: some View {
        HStack {
            VStack(spacing: 5) {
                PerformanceSettingBarView()
                PerformaceChartView()
            }
            .environmentObject(deviceService)
            .environmentObject(performance)
            
            if performance.isShowPerformanceSummary {
                PerformanceSummaryView()
                    .padding(.leading, 5)
                    .frame(width: 250)
                    .background {
                        Color.fabulaBack1
                    }
                    .transition(
                        .move(
                            edge: .trailing
                        )
                    )
                    .environmentObject(deviceService)
                    .environmentObject(performance.summary)
            }
        }
        .animation(.default, value: performance.isShowPerformanceSummary)
    }
}

