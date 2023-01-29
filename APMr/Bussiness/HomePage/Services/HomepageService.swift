//
//  HomepageService.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/10.
//

import Foundation

enum HomepageServiceType: Codable {
    case performance
    
    case launch
    
    case lag
    
    case crash
}

class HomepageService: ObservableObject {
    
    // MARK: - Sider -
    @Published var selectionSider: ApplicationSider = (siders.first)!
    public static let siders = [ApplicationSider(state: .performance, title: "性能测评"),
                                ApplicationSider(state: .launch, title: "启动分析"),
                                ApplicationSider(state: .lag, title: "卡顿分析"),
                                ApplicationSider(state: .crash, title: "崩溃分析")]
        
    // MARK: - Navigation Bar -
    @Published var selectDevice: DeviceItem? = nil
    @Published var selectApp: IInstproxyAppInfo? = nil

    // MARK: - Performance Summary -
    @Published public var isShowPerformanceSummary = false
}
