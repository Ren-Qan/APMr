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
    @Published var isShowPerformanceSummary = false {
        didSet {
            if !isShowPerformanceSummary {
                testSummaryRegion.len = 0
            }
        }
    }

    public var recordDuration = 2 * 60 * 60
    public var samplingTime: TimeInterval = 1
    public var sampleFragmentTime: TimeInterval = 5 * 1 * 60
    
    // MARK: - Test Data -
    
    @Published var testSummaryRegion: (x: Int, len: Int) = (0, 0)
        
    @Published public var testDatas = [TestItem(id: "CPU"),
                                       TestItem(id: "FPS"),
                                       TestItem(id: "Memory"),
                                       TestItem(id: "GPU"),
                                       TestItem(id: "Network"),
                                       TestItem(id: "I/O"),
                                       TestItem(id: "Battery")]
    
    public var summaryData: [TestChartItem] {
        if testSummaryRegion.len == 1 {
            return [testChartItems.randomElement()!]
        } else {
            let len = Int.random(in: 0 ..< 300)
            let x = Int.random(in: 0 ..< (300 - len))
            return Array(testChartItems[x..<(x + len)])
        }
    }
    
    public let testChartItems: [TestChartItem] = {
        var items = [TestChartItem]()
        
        (0 ..< 300).forEach { x in
            let item = TestChartItem(x: x, y: .random(in: 0 ... 105))
            items.append(item)
        }
        
        return items
    }()
}

// MARK: - Test Func -

extension HomepageService {
    public func updatePerformanceChartShow(_ item: TestItem) {
        let id = item.id
        let index = testDatas.firstIndex { item in
            return id == item.id
        }
        
        if let index = index {
            testDatas[index].chartViewShow = item.chartViewShow
        }
    }
}

struct TestItem: Identifiable {
    var id: String
    
    var chartViewShow: Bool = true
}

struct TestChartItem: Identifiable {
    var id = UUID()
    
    var x: Int
    var y: Double
}
