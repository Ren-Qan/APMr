//
//  IPlate.swift
//  APMr
//
//  Created by 任玉乾 on 2023/11/13.
//

import SwiftUI

extension IPerformanceView {
    struct IPlate: NSViewRepresentable {
        @EnvironmentObject var device: ADevice
        @EnvironmentObject var performance: CPerformance
        
        typealias NSViewType = NSIPlate
        
        func makeNSView(context: Context) -> IPerformanceView.NSIPlate {
            let plate = NSIPlate()
            setup(plate)
            return plate
        }
        
        func updateNSView(_ nsView: IPerformanceView.NSIPlate, context: Context) {
            setup(nsView)
        }
        
        private func setup(_ nsView: IPerformanceView.NSIPlate) {
            nsView.target = self
            nsView.refresh()
        }
    }
}
