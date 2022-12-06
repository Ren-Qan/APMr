//
//  BarChartView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/4.
//

import SwiftUI
import Charts


struct BarChartView: View {
    var marks : [LandMarkItem]
    
    var ruleY: CGFloat = 50
    
    var body: some View {
        LazyVStack {
            Spacer(minLength: 10)
            
            Chart(marks) { mark in
                BarMark(x: .value("date", mark.x),
                        y: .value("present", Int(mark.y * 10)),
                        width: .fixed(3)
                )
                .foregroundStyle(mark.y <= ruleY ? Color.blue.gradient : Color.orange.gradient)
                
                RuleMark(
                    y: .value("use", Int(ruleY * 10))
                )
                .lineStyle(StrokeStyle(lineWidth: 1))
                .foregroundStyle(.red.gradient)
                    
            }
            .frame(height: 150)
            .chartXScale(domain: 0 ... 300)
            .chartYScale(domain: 0 ... 1000)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic) { value in
                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.5))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue / 10) %")
                            .font(.system(size: 10))
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: .automatic(desiredCount: 30)) { value in
                    AxisGridLine(centered: true, stroke: StrokeStyle(lineWidth: 0.5))
                    AxisValueLabel() {
                        if let intValue = value.as(Int.self) {
                            Text("\(intValue) s")
                            .font(.system(size: 10))
                        }
                    }
                }
            }
        }
    }
}



