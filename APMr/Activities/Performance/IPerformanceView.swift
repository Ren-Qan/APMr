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
                performance.chart.group.reset()
            }
             
            Button("real Sample [\(performance.sampleCount)]") {
                if let p = device.selectPhone, let app = device.selectApp {
                    performance.start(p, app)
                    performance.chart.group.reset()
                }
            }
        }
        .padding(.top, 10)
        #endif
        
        ITableView()
            .environmentObject(performance.chart.group)
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity)
    }
}
