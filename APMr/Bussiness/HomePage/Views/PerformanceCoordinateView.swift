//
//  PerformanceCoordinateView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/14.
//

import SwiftUI
import Charts

protocol PerformanceCoordinateViewMarkProtocol: Identifiable {
    var x: Int { get }
    var y: Int { get }
    var tips: String { get }
}

struct PerformanceCoordinateView<Mark, Content>: View where Mark: PerformanceCoordinateViewMarkProtocol, Content: ChartContent {
    
    public var lineSpace: CGFloat = 25
    public var xAxisExtraPadding = 10
    public var maxY = 100
    
    var items: [Mark]
    var content: (Mark, Int) -> Content
    
    @State private var selectX = -1
    
    var body: some View {
        GeometryReader { rootProxy in
            ScrollView(.horizontal) {
                Chart {
                    ForEach(items) { item in                        
                        content(item, selectX)
                    }
                }
                .padding(.leading, 10)
                .padding(.top, 10)
                .chartYScale(domain: 0 ... maxY)
                .chartXScale(domain: 0 ... xScale(rootProxy.size.width))
                .frame(width: chartWidth(rootProxy.size.width))
                .chartLegend(position: .top, alignment: .center)
                .chartLegend(.visible)
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: xScale(rootProxy.size.width))) { value in
                        if let x = value.as(Int.self) {
                            if x % 5 == 0 {
                                AxisTick(stroke: .init(lineWidth: 1))
                                    .foregroundStyle(.gray)
                                AxisValueLabel() {
                                    Text("\(x)")
                                }
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartOverlay { proxy in
                    GeometryReader { g in
                        Rectangle().fill(.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let x = value.location.x - g[proxy.plotAreaFrame].origin.x
                                        if let index: Int = proxy.value(atX: x), index < items.count {
                                            selectX = index
                                        }
                                    }
                            )
                    }

                }
            }
        }
    }
    
    private func chartWidth(_ rootWidth: CGFloat) -> CGFloat {
        return CGFloat(xScale(rootWidth)) * lineSpace
    }
    
    private func xScale(_ width: CGFloat) -> Int {
        let widthCount = Int(width / lineSpace) + 1
        return (widthCount > items.count ? widthCount : items.count) + xAxisExtraPadding
    }
}
