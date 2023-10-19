//
//  IDetailSideView+Section.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/12.
//

import SwiftUI

extension IPerformanceView.IDetailSideView {
    struct Section: View {
        var group: CPerformance.Chart.Group
        
        @EnvironmentObject var snap: CPerformance.Chart.Highlighter.Snap
        
        var body: some View {
            Text("\(snap.index)")
            ForEach(group.notifiers) { notifier in
                Text("\(notifier.type.text) - \(snap.index)")
            }
        }
    }
    
    struct N: View {
        var index: Int
        var notifier: CPerformance.Chart.Notifier
                
        init(index: Int, notifier: CPerformance.Chart.Notifier) {
            self.index = index
            self.notifier = notifier
        }
        
        var body: some View {
            ForEach(notifier.graph.series) { series in
                let value = series.marks[index]
                let unit = "\(value.source.unit)"
                HStack {
                    Text("\(index)")
                    Text("\(value.label)")
                    Text("\(value.source.value)")
                    Text(unit)
                }
            }
        }
    }
}
