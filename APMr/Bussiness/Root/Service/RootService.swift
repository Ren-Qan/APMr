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
    ]
#else
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
    }
    
    struct Sider: Identifiable, Hashable, Codable {
        let state: S
        let title: String
        var id = UUID()
    }
}
