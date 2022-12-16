//
//  HomepageContentView.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import SwiftUI

struct ID: Identifiable {
    var id: Int { item }
    var item: Int
}

struct HomepageContentView: View {
    @ObservedObject private var deviceService = HomepageDeviceService()
    
    @ObservedObject private var instrumentService = HomepageInstrumentsService()
        
    @State var isShow = false
    
    var items: [ID] = {
        var items = [ID]()
        (0 ..< 200).forEach { i in
            items.append(.init(item: i))
        }
        return items
    }()
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .center, spacing: 10) {
                PerformanceCoordinateView()
                    .frame(height: 190)
            }
        }
        .onAppear {
            deviceService.refreshDeviceList()
        }
        .navigationTitle("")
        .frame(minWidth: 800)
        .frame(minHeight: 250)
    }
}
