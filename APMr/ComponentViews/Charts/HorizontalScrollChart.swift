//
//  HorizontalScrollChart.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/16.
//

import SwiftUI
import Charts

struct HorizontalScrollChart<Content, Item>: View where Item: Identifiable,
                                                        Content : ChartContent {
    @Binding var chartDatas: [Item]
    var content: (Item) -> Content
    
    @State public var padding: CGFloat = 22
    
    var body: some View {
        GeometryReader { rootProxy in
            ScrollView(.horizontal) {
                Chart {
                    ForEach(chartDatas) { item in
                        content(item)
                    }
                }
                .chartXScale(domain: 0 ... xScale(rootProxy.size.width - 10))
                .frame(width: chartWidth(rootProxy.size.width - 10))
                .offset(x: 10)
            }
        }
    }
    
    private func chartWidth(_ rootWidth: CGFloat) -> CGFloat {
        let dataWidth = padding * CGFloat(xScale(rootWidth))
        return dataWidth
    }
    
    private func xScale(_ rootWidth: CGFloat) -> Int {
        let screenXScale = Int(rootWidth / padding)
        return (screenXScale > chartDatas.count ? screenXScale : chartDatas.count) + 10
    }
}

