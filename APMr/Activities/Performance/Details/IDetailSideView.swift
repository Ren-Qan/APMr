//
//  IDetailSideView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/10/11.
//

import SwiftUI

extension IPerformanceView {
    struct IDetailSideView: View {
        @EnvironmentObject
        var highlighter: CPerformance.Chart.Highlighter
        var group: CPerformance.Chart.Group
        
        var body: some View {
            ScrollView {
                LazyVStack(spacing: 5) {
                    ForEach(highlighter.snaps) { snap in
                        Text("\(snap.index)")
                    }
                }
            }
        }
    }
}
