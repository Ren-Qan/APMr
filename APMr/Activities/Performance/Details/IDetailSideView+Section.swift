//
//  IDetailSideView+Section.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/12.
//

import SwiftUI

extension IPerformanceView.IDetailSideView {
    struct Section: View {
        var snapIndex: Int
        @EnvironmentObject var group: CPerformance.Chart.Group
        
        var body: some View {
            Text("\(snapIndex) S")
            ForEach(group.notifiers) { notifier in
                Text(notifier.type.text)
                ForEach(notifier.graph.series) { series in
                    HStack {
                        let mark = series.marks[snapIndex]
                        Text(mark.label)
                        Text("\(String(format: "%.1f", mark.source.value))")
                        Text(mark.source.unit.format)
                    }
                }
            }
        }
    }
}
