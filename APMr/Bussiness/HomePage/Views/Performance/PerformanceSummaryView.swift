//
//  PerformanceSummaryView.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/16.
//

import SwiftUI

struct PerformanceSummaryView: View {
    @EnvironmentObject var service: HomepageService
    
    let testColumns: [GridItem] = {
        var items = [GridItem]()
        
        (0 ..< 100).forEach { i in
            let item = GridItem(.fixed(100), spacing: 5)
            items.append(item)
        }
        return items
    }()
    
    var body: some View {
        ScrollView {
            Text("In Progress")
        }
    }
}
