//
//  PerformanceView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/10.
//

import SwiftUI

struct PerformanceView: View {
    
    @EnvironmentObject var service: HomepageService
            
    var body: some View {
        HStack {
            VStack {
                PerformanceSettingBarView()
                    .environmentObject(service)
                
                GeometryReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(service.testDatas) { item in
                                Text(item.id)
                                    .fontDesign(.monospaced)
                                    .frame(height: 300)
                                    .frame(width: proxy.size.width)
                                    .padding(.bottom, 20)
                                    .background {
                                        Color.fabulaBack1
                                    }
                            }
                        }
                    }
                }
            }
            
            if service.isShowPerformanceSummary {
                PerformanceSummaryView()
                    .frame(minWidth: 300)
            }
        }
        .animation(.default, value: service.isShowPerformanceSummary)
    }
}

