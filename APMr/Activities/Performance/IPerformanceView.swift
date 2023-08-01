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
            Button("[\(performance.sampleCount)] sample") {
                performance.Debug_sample()
//                if let p = device.selectPhone, let app = device.selectApp {
//                    performance.start(p, app)
//                }
            }
            
            Button("[\(performance.sampleCount)] Device") {
//                performance.Debug_sample()
                if let p = device.selectPhone, let app = device.selectApp {
                    performance.start(p, app)
                }
            }
        }
        .padding(.top, 10)
        #endif
        
        ZStack {
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
    fileprivate struct ScrollControl: View {
        @EnvironmentObject var performance: CPerformance
        
        var body: some View {
            ScrollView(.horizontal) {
                
            }
        }
    }
}

extension IPerformanceView {
//    fileprivate struct EventView: View {
//        @EnvironmentObject var performance: CPerformance
//
//        var body: some View {
//            IEventHandleView()
//                .onEvent { event in
//                    performance.hint.sync(event)
//                }
//        }
//    }
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
