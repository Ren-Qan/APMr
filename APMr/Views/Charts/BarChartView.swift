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
    
    var body: some View {
        Group {
            Chart(marks) { mark in
                BarMark(x: .value("date", mark.x),
                        y: .value("present", Int(mark.y * 10)),
                        width: .fixed(3)
                )
            }
            .chartXScale(domain: -1 ... 300)
            .chartYScale(domain: -1 ... 1000)
        }
    }
}



