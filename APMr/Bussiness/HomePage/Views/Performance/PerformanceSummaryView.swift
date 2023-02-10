//
//  PerformanceSummaryView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/16.
//

import SwiftUI

struct PerformanceSummaryView: View {
    @EnvironmentObject var service: HomepageService
    
    @EnvironmentObject var summary: HomepageInstrumentsService.Summary
            
    var body: some View {
        Text("\(summary.highlightState.start) ---- \(summary.highlightState.end)")
    }
}
