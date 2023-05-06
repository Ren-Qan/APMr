//
//  HomepageService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/10.
//

import Foundation

class Service: ObservableObject {
#if DEBUG
    public static let siders = [
        Sider(state: .performance, title: "性能测评"),
        Sider(state: .launch, title: "启动分析"),
        Sider(state: .lag, title: "卡顿分析"),
        Sider(state: .crash, title: "崩溃分析"),
    ]
#elseif RELEASE
    public static let siders = [
        Sider(state: .performance, title: "性能测评"),
    ]
#endif

    @Published var selection: Sider = (siders.first)!
}

extension Service {
    enum S: Codable {
        case performance
        
        case launch
        
        case lag
        
        case crash
    }
    
    struct Sider: Identifiable, Hashable, Codable {
        var state: S
        
        var title: String
        
        var id: UUID
        
        init(state: S, title: String) {
            self.state = state
            self.title = title
            self.id = UUID()
        }
    }
}
