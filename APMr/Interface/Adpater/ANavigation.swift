//
//  ANavigation.swift
//  APMr
//
//  Created by 任玉乾 on 2023/6/27.
//

import Foundation

class ANavigation: ObservableObject {
#if DEBUG
    public static let siders = [
        Sider(state: .performance),
        Sider(state: .launch),
    ]
#else
    public static let siders = [
        Sider(state: .performance),
    ]
#endif

    @Published var selection: Sider = siders.first!
}

extension ANavigation {
    enum S: Codable {
        case performance
        case launch
        
        var title: String {
            switch self {
                case .performance: return "性能测评"
                case .launch: return "启动分析"
            }
        }
    }
    
    struct Sider: Identifiable, Hashable, Codable {
        var id = UUID()
        let state: S
        
        var title: String {
            return state.title
        }
    }
}
