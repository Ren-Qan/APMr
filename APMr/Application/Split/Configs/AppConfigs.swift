//
//  AppConfigs.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/9.
//

import Cocoa

enum SiderState: Codable {
    case performance
    
    case other
}

struct AppConfigs {
    static let siders: [AppSider] = [
        AppSider(state: .performance, title: "性能测评"),
        AppSider(state: .other, title: "Test")
    ]
}

struct AppSider: Identifiable, Hashable, Codable {
    var state: SiderState
    
    var title: String
    
    var id: UUID
    
    init(state: SiderState, title: String) {
        self.state = state
        self.title = title
        self.id = UUID()
    }
}
