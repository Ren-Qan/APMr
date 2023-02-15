//
//  PerformanceSummaryView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/16.
//

import SwiftUI

struct PerformanceSummaryView: View {
    @EnvironmentObject var service: HomepageService
    
    @EnvironmentObject var summary: PerformanceInstrumentsService.Summary
            
    var body: some View {
        ScrollView {
            ForEach(summary.highlightDatas) { item in
                Cell(forceOpen: summary.highlightDatas.count == 1)
                    .environmentObject(item)
            }
        }
    }
}

extension PerformanceSummaryView {
    struct Cell: View {
        @EnvironmentObject var item: PerformanceInstrumentsService.SummaryItem
        var forceOpen: Bool
        
        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees((item.isOpen || forceOpen) ? 90 : 0))
                        .padding(.leading, 5)
                    Text("第\(item.time)秒报告")
                        .frame(maxWidth: .infinity,
                               alignment: .leading)
                }
                .background {
                    Color.clear
                }
                .onTapGesture {
                    if !forceOpen {
                        withAnimation(.easeIn(duration: 0.15)) {
                            item.isOpen.toggle()
                        }
                    }
                }
                
                if item.isOpen || forceOpen {
                    HStack {
                        Color.fabulaFore2
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
                } else {
                    Divider()
                }
            }
            .padding(.top, 1)
        }
    }
}

extension PerformanceSummaryView {
    struct CD: View {
        @EnvironmentObject var info: PerformanceInstrumentsService.SummaryItemInfo
                
        var body: some View {
            VStack(alignment: .leading) {
                Text("\(info.title) 报告")
                    .font(.subheadline)
                    .padding(.bottom, 2)
                
                ZStack(alignment: .leading) {
                    Text(" 指标")
                    Text("值")
                        .offset(x: 90)
                    Text("单位")
                        .offset(x: 150)
                }
                .frame(maxWidth: .infinity,
                       alignment: .leading)
                .padding(.bottom, 1.5)
                
                ForEach(info.values) { value in
                    ZStack(alignment: .leading) {
                        V(value: value)
                    }
                }
                
                Divider()
                    .background {
                        Color.fabulaBack2
                    }
            }
        }
    }
}

extension PerformanceSummaryView {
    struct V: View {
        @State private var onHover: Bool = false
        
        var value: PerformanceInstrumentsService.SummaryItemValue
        
        var body: some View {
            ZStack(alignment: .leading) {
                Text(" \(value.name):")
                    .font(.callout)
                Text("\(value.formateValue)")
                    .offset(x: 90)
                Text("\(value.unit)")
                    .offset(x: 150)
            }
            .padding(.bottom, 1)
            .frame(maxWidth: .infinity,
                   alignment: .leading)
            .background {
                Color.fabulaFore2
                    .padding(.trailing, 10)
                    .opacity(onHover ? 1 : 0)
            }
            .onHover { on in
                onHover = on
            }
        }
    }
}
