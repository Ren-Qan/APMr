//
//  PerformanceView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/10.
//

import SwiftUI

struct PerformanceView: View {
    
    @EnvironmentObject var service: HomepageService
    
    @EnvironmentObject var performance: PerformanceInstrumentsService
    
    var body: some View {
        HStack {
            VStack(spacing: 5) {
                PerformanceSettingBarView()
                PerformaceChartView()
            }
            .environmentObject(service)
            .environmentObject(performance)
            
            if service.isShowPerformanceSummary {
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
                    .environmentObject(service)
                    .environmentObject(performance.summary)
            }
        }
        .animation(.default, value: service.isShowPerformanceSummary)
    }
}

