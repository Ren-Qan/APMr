//
//  PerformanceSummaryView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/16.
//

import SwiftUI

struct PerformanceSummaryView: View {
    @EnvironmentObject var service: HomepageService
    
    var body: some View {
        VStack {
            Text("StartX: \(service.summaryRegion.x)\nLen:\(service.summaryRegion.len)")
                .multilineTextAlignment(.leading)
        }
    }
}
