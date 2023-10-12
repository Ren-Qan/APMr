//
//  IDetailSideView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/11.
//

import SwiftUI

extension IPerformanceView {
    struct IDetailSideView: View {
        @EnvironmentObject var highlighter: CPerformance.Chart.Highlighter
        @EnvironmentObject var group: CPerformance.Chart.Group
        
        var body: some View {
            if let indexRange = group.highlighter.range(group.snapCount) {
                ScrollView {
                    LazyVStack {
                        ForEach(indexRange, id: \.self) { index in
                            IDetailSideView
                                .Section(snapIndex: index)
                                .environmentObject(group)
                        }
                    }
                }
            } else {
                Text("待选中数据")
            }
        }
    }
}
