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
            Button("start") {
                performance.start()
            }
            
            Debug_T().environmentObject(performance)
        }
        #endif
        
        ZStack {
            EventView()
                .environmentObject(performance)
  
    
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(performance.chart.models) { model in
                        Cell()
                            .environmentObject(model.line)
                            .environmentObject(model.axis)
                            .environmentObject(performance.event.hint)
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

    
    fileprivate struct Cell: View {
        @EnvironmentObject var line: CPerformance.Chart.Model.Line
        @EnvironmentObject var axis: CPerformance.Chart.Model.Axis
        @EnvironmentObject var hint: CPerformance.Event.Hint
        
        var body: some View {
            ZStack {
                IPerformanceView.LineView()
                    .environmentObject(line)
                    .environmentObject(axis)
                
                IPerformanceView.HintView()
                    .environmentObject(hint)
            }
            .frame(minHeight: 200)
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
