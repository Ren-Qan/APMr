//
//  PerformanceCoordinateView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/14.
//

import SwiftUI
import Charts

struct LandMarkItem: Identifiable {
    var id: Int { x }
    
    var x: Int = 0
    
    var y: CGFloat = 0
}

struct PerformanceCoordinateView: View {
    @State var datas: [LandMarkItem] = []
    
    @State var padding: CGFloat = 22
    @State var lineWidth: CGFloat = 3
    
    var body: some View {
        VStack(spacing: 10) {
            Button("Click") {
                let x = datas.count
                var item = LandMarkItem()
                item.x = x
                item.y = CGFloat.random(in: 0 ..< 100)
                datas.append(item)
            }
            
            HorizontalScrollChart(chartDatas: $datas) { data in
                LineMark(x: .value("x", data.x),
                         y: .value("y", Int(data.y * 10)))
                .foregroundStyle(.orange)
                .interpolationMethod(.cardinal)
            }
            .chartYScale(domain: 0 ... 1000)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: datas.count + 10)) { value in
                    if let x = value.as(Int.self) {
                        if x % 5 == 0 {
                            AxisTick(stroke: .init(lineWidth: 1))
                                .foregroundStyle(.gray)
                            AxisValueLabel() {
                                Text("\(x)s")
                            }
                            AxisGridLine(stroke: .init(lineWidth: 1))
                                .foregroundStyle(.gray)
                        } else {
                            AxisGridLine(stroke: .init(lineWidth: 1))
                                .foregroundStyle(.gray.opacity(0.25))
                        }

                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine(stroke: .init(lineWidth: 1))
                        .foregroundStyle(.gray.opacity(0.25))
                }
            }
        }
    }
}
