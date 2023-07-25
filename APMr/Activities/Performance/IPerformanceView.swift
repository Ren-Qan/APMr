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
        VStack {
            
        }
        #if DEBUG
        HStack {
            Button("insert random Data") {
                performance.Debug_sample()
            }

            Debug_T()
                .environmentObject(performance.hint)
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
    fileprivate struct ScrollControl: View {
        @EnvironmentObject var performance: CPerformance
        
        var body: some View {
            ScrollView(.horizontal) {
                
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
                    performance.hint.sync(event)
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
    @EnvironmentObject var hint: CPerformance.Hint
    
    var body: some View {
        switch hint.interactive {
            case .empty:
                Text("empty")
            case .drag(let area):
                let t = "\(area)"
                Text(t)
            case .click(let location):
                let t = "\(location)"
                Text(t)
            case .begin:
                let t = "begin"
                Text(t)
        }
    }
}
#endif
