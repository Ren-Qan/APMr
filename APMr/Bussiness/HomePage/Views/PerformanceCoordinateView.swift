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
            
            GeometryReader { rootProxy in
                ScrollView(.horizontal) {
                    Chart {
                        ForEach(datas) { item in
                            BarMark(x: .value("x", item.x),
                                    y: .value("y", Int(item.y)),
                                    width: .init(floatLiteral: lineWidth))
                        }
                    }
                    .chartXScale(domain: 0 ... xScale(rootProxy.size.width - 10))
                    .chartYScale(domain: 0 ... 100)
                    .frame(width: chartWidth(rootProxy.size.width - 10))
                    .offset(x: 10)
                }
                
            }
            
            Slider(value: $padding,
                   in: 22 ... 100)
            {
                Text("Padding:\(padding)")
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
            
            Slider(value: $lineWidth,
                   in: 3 ... 10)
            {
                Text("LineWidth:\(lineWidth)")
            }
            .padding(.leading, 10)
            .padding(.trailing, 10)
        }
    }
    
    private func chartWidth(_ rootWidth: CGFloat) -> CGFloat {
        let dataWidth = (padding + lineWidth) * CGFloat(xScale(rootWidth))
        return dataWidth
    }
    
    private func xScale(_ rootWidth: CGFloat) -> Int {
        let screenXScale = Int(rootWidth / (padding + lineWidth))
        return screenXScale > datas.count ? screenXScale : datas.count
    }
}
