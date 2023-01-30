//
//  HomepageModels.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/20.
//

import Foundation

// MARK: - 侧边功能按钮模型 -
struct ApplicationSider: Identifiable, Hashable, Codable {
    var state: HomepageServiceType
    
    var title: String
    
    var id: UUID
    
    init(state: HomepageServiceType, title: String) {
        self.state = state
        self.title = title
        self.id = UUID()
    }
}

struct PerformanceChartSetting: Identifiable {
    var id = UUID()
    
    var title: String
    
    var isHidden: Bool
}
