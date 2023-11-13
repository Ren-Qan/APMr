//
//  IManagerBar.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/13.
//

import SwiftUI

extension IPerformanceView {
    struct IManagerBar: View {
        @EnvironmentObject var device: ADevice
        @EnvironmentObject var performance: CPerformance
        
        var body: some View {
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
        }
    }
}
