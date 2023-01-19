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
            ForEach(service.summaryData) { item in
                LazyVStack {
                    Text("第\(item.x)秒性能报告")
                    ForEach(service.testDatas) { data in
                        if data.chartViewShow {
                            Text(data.id)
                            Group {
                                ForEach((1..<4)) { id in
                                    HStack {
                                        Text("指标\(id)")
                                        Text("value")
                                    }
                                }
                            }
                        }
                    }
                }
                .background {
                    Color.fabulaBack2
                }
            }
        }
        .frame(maxWidth: 350)
    }
}
