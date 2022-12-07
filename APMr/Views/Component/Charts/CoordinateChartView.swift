//
//  CoordinateChartView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import SwiftUI

struct CoordinateChartView: View {
    @State private var offsetY: CGFloat = 0
    @State private var ruleY: CGFloat = 50
    @State private var ruleLineIsHidden = true
    var items : [LandMarkItem] = []
    
    var body: some View {
        VStack {
            ZStack(alignment: .trailing) {
                BarChartView(marks: items, ruleY: ruleY)
                    .frame(height: 170)
                    .padding(.leading, 10)
                    .padding(.trailing, 20)
                
                HStack {
                    Text(String(format: "%.1f%%", 100 * (1 - (offsetY + 70) / 135)))
                        .font(.system(size: 10, weight: .medium))
                        .offset(x: 10)
    
                    Color.gray
                        .background(Color.black.opacity(0.5))
                        .frame(height: 1)
                        .opacity(ruleLineIsHidden ? 0 : 1)
                        .padding(.leading, 5)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged{ value in
                            let newOffsetY = offsetY + value.location.y - value.startLocation.y
                            
                            if newOffsetY >= -70, newOffsetY <= 65 {
                                offsetY = newOffsetY
                                ruleLineIsHidden = false
                            }
                        }
                        .onEnded{ value in
                            ruleY = 100 * (1 - (offsetY + 70) / 135)
                            ruleLineIsHidden = true
                        }
                )
                .offset(y: offsetY)
                .padding(.trailing, 20)
                
            }
        }
    }
}
