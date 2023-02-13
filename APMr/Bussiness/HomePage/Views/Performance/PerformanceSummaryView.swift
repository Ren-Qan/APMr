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
        ScrollView {
            ForEach(summary.highlightDatas) { item in
                Cell()
                    .environmentObject(item)
            }
        }
    }
}

extension PerformanceSummaryView {
    struct Cell: View {
        @EnvironmentObject var item: HomepageInstrumentsService.SummaryItem
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(item.isOpen ? 90 : 0))
                        .padding(.leading, 5)
                    Text("第\(item.time)秒报告")
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                }
                .onTapGesture {
                    withAnimation(.easeIn(duration: 0.15)) {
                        item.isOpen.toggle()
                    }
                }
                
                if item.isOpen {
                    HStack {
                        Color.random
                            .frame(width: 1)
                            .padding(.leading, 9)
                                                    
                        VStack(alignment: .leading) {
                            ForEach(item.values) { value in
                                CD()
                                    .padding(.bottom, 2)
                                    .environmentObject(value)
                            }
                        }
                        .padding(.leading, 6)
                    }
                }
            }
            .padding(.top, 1)
        }
    }
}

extension PerformanceSummaryView {
    struct CD: View {
        @EnvironmentObject var info: HomepageInstrumentsService.SummaryItemInfo
                
        var body: some View {
            VStack(alignment: .leading) {
                Text("\(info.title)使用报告")
  
                ForEach(info.values) { value in
                    ZStack(alignment: .leading) {
                        Text("\(value.name)")
                            .offset(x: 6)
                        Text("\(value.value)")
                            .offset(x: 110)
                    }
                }
            }
            
        }
    }
}
