//
//  PerformanceView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/10.
//

import SwiftUI

struct PerformanceView: View {
    
    @EnvironmentObject var service: HomepageService
            
    var body: some View {
        HStack {
            VStack {
                PerformanceSettingBarView()
                PerformaceChartView()
            }
            .environmentObject(service)
            
            if service.isShowPerformanceSummary {
                PerformanceSummaryView()
                    .padding(.leading, 5)
                    .frame(minWidth: 200)
                    .background {
                        Color.fabulaBack1
                    }
            }
        }
        .animation(.default, value: service.isShowPerformanceSummary)
    }
}

