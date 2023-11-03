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
        #if DEBUG
        HStack {
            Button("Debug Sample [\(performance.sampleCount)]") {
                performance.Debug_sample()
            }
             
            Button("real Sample [\(performance.sampleCount)]") {
                if let p = device.selectPhone,
                   let app = device.selectApp {
                    performance.start(p, app)
                }
            }
                                    
            Button("\(performance.isNeedShowDetailSide ? "关" : "开")") {
                performance.isNeedShowDetailSide.toggle()
            }
        }
        .padding(.top, 10)
        #endif
        
        HStack(spacing: 0) {
            ICharts()
                .environmentObject(performance.chart.group)
                .environmentObject(performance.chart.actor)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
            
            if performance.isNeedShowDetailSide {
                ICharts.ISides()
                    .environmentObject(performance.chart.actor.hilighter.snap)
                    .frame(maxWidth: 250)
                    .frame(maxHeight: .infinity)
            }
        }
    }
}
