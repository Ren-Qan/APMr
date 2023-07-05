//
//  IPerformanceView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/6/27.
//

import SwiftUI

struct IPerformanceView: View {
    @EnvironmentObject var performance: CPerformance
    
    @EnvironmentObject var device: ADevice
        
    var body: some View {
        #if DEBUG
        HStack {
            Button("start") {
                performance.start()
            }
            
            T().environmentObject(performance.event)
        }
        #endif
        
        ZStack {
            EventView()
                .environmentObject(performance)
            
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(performance.chart.models) { model in
                        Cell()
                            .environmentObject(model)
                    }
                }
            }
        }
    }
}

fileprivate struct EventView: View {
    @EnvironmentObject var p: CPerformance

    var body: some View {
        IEventHandleView()
            .onEvent { event in
                self.p.sync(event: event)
            }
    }
}

fileprivate struct Cell: View {
    @EnvironmentObject var model: CPerformance.Chart.M
    
    var body: some View {
        ZStack {
            IPerformanceView.LineView()
            IPerformanceView.HintView()
        }
        .environmentObject(model)
        .frame(minHeight: 200)
        .background {
            Color.orange
        }
    }
}


fileprivate struct T: View {
    @EnvironmentObject var event: AEvent
    
    var body: some View {
        Text("[\(event.type)] - X: \(event.point.x) Y:\(event.point.y)")
    }
}
