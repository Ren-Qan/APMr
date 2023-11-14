//
//  IPerformanceView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/6/27.
//

import SwiftUI

struct IPerformanceView: View {
    @EnvironmentObject var device: ADevice
    @EnvironmentObject var performance: CPerformance
    
    var body: some View {
        VStack(spacing: 0) {
            IPlate()
                .frame(maxHeight: 45)
                .environmentObject(device)
                .environmentObject(performance)
            
            HStack(spacing: 10) {
                ICharts()
                    .environmentObject(performance.chart.group)
                    .environmentObject(performance.chart.actor)
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: .infinity)
                
                if performance.isNeedShowDetailSide {
                    ICharts.ISides()
                        .environmentObject(performance.chart.actor.hilighter.snap)
                        .frame(maxWidth: 255)
                        .frame(maxHeight: .infinity)
                }
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            .background {
                Color.box.BG1
            }
        }
    }
}
