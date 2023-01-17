//
//  PerformaceChartView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/17.
//

import SwiftUI

struct PerformaceChartView: View {
    @EnvironmentObject var service: HomepageService
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                LazyVStack {
                    ForEach(service.testDatas) { item in
                        if item.chartViewShow {
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
    }
}
