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
            let string =
        """
        range:\(group.highlighter.range(group.snapCount))
        """
            Text(string)
        }
    }
}
