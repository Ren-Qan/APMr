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
    
    case crash
    
    case lag
}

struct TestItem: Identifiable {
    var id: String
}

class HomepageService: ObservableObject {
    
    // MARK: - Sider -
    static let siders = [
        ApplicationSider(state: .performance, title: "性能测评"),
        ApplicationSider(state: .launch, title: "启动分析"),
        ApplicationSider(state: .lag, title: "卡顿分析"),
        ApplicationSider(state: .crash, title: "崩溃分析")
    ]
    
    @Published var selectionSider: ApplicationSider = (siders.first)!
    
    // MARK: - Tool Bar -
    @Published var selectDevice: DeviceItem? = nil
    @Published var selectApp: IInstproxyAppInfo? = nil
    
    // MARK: - Performance -
    @Published var isMonitoringPreformance = false
    @Published var isShowPerformanceSummary = false
    
    // MARK: - Test Data -
    let testDatas = [TestItem(id: "CPU"), TestItem(id: "FPS"), TestItem(id: "Memory"), TestItem(id: "GPU"), TestItem(id: "Network"), TestItem(id: "I/O"), TestItem(id: "Battery")]
}

extension HomepageService {

}
