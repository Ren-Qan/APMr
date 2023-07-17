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
            Button("\(performance.isRunning ? "stop" : "start")") {
                if performance.isRunning {
                    performance.stop()
                    return
                }
                guard let phone = device.selectPhone,
                        let app = device.selectApp else {
                    return
                }
                performance.start(phone, app)
            }

            Debug_T().environmentObject(performance)
        }
        .padding(.top, 10)
        #endif
        
        ZStack {
            EventView()
                .environmentObject(performance)
  
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(performance.chart.notifiers) { notifier in
                        IPerformanceView.GraphView()
                            .frame(minHeight: 200)
                            .environmentObject(notifier)
                            .environmentObject(performance.hint)
                    }
                }
            }
        }
    }
}

extension IPerformanceView {
    fileprivate struct EventView: View {
        @EnvironmentObject var performance: CPerformance

        var body: some View {
            IEventHandleView()
                .onEvent { event in
                    self.performance.interact(event)
                }
        }
    }
}

extension IPerformanceView {
    class Element: CAShapeLayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
    
    class Text: CATextLayer {
        override func action(forKey event: String) -> CAAction? {
            return nil
        }
    }
}


#if DEBUG
fileprivate struct Debug_T: View {
    var body: some View {
        Text("Event Sync")
    }
}
#endif