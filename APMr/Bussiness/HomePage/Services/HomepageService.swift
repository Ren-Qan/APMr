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
    
    var chartViewShow: Bool = true
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
    
    // MARK: - Navigation Bar -
    @Published var selectDevice: DeviceItem? = nil
    @Published var selectApp: IInstproxyAppInfo? = nil
    
    // MARK: - Performance -
    @Published var isMonitoringPerformance = false
    @Published var isShowPerformanceSummary = false

    var recordDuration = 2 * 60 * 60
    var samplingTime: TimeInterval = 1
    var sampleFragmentTime: TimeInterval = 5 * 1 * 60
    
    
    // MARK: - Test Data -
    @Published var testDatas = [TestItem(id: "CPU"),
                                TestItem(id: "FPS"),
                                TestItem(id: "Memory"),
                                TestItem(id: "GPU"),
                                TestItem(id: "Network"),
                                TestItem(id: "I/O"),
                                TestItem(id: "Battery")]
    
    func updatePerformanceChartShow(_ item: TestItem) {
        let id = item.id
        let index = testDatas.firstIndex { item in
            return id == item.id
        }
        
        if let index = index {
            testDatas[index].chartViewShow = item.chartViewShow
        }
    }
}

extension HomepageService {

}
