//
//  IPerformanceView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/6/27.
//

import SwiftUI

struct IPerformanceView: View {
    @EnvironmentObject var performance: PerformanceService
    
    @EnvironmentObject var deviceService: DeviceService
    
    var body: some View {
        Text("In Process")
    }
}
