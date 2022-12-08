//
//  HomepageService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/7.
//

import Cocoa
import Combine

struct HomepageChartModel: Identifiable {
    var id: String { serviceName.rawValue }
    var title: String = ""
    var items: [LandMarkItem] = []
    var serviceName: IInstrumentsServiceName
}

class HomepageService: NSObject, ObservableObject {
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let group = IInstrumentsServiceGroup()
        group.config(types: [.sysmontap, .opengl])
        group.delegate = self
        return group
    }()
    
    @Published public var cpu = {
        var item = HomepageChartModel(serviceName: .sysmontap)
        item.title = "CPU"
        return item
    }()
    
    @Published public var gpu = {
        var item = HomepageChartModel(serviceName: .opengl)
        item.title = "GPU"
        return item
    }()
}

extension HomepageService: IInstrumentsServiceGroupDelegate {
    func sysmontap(sysmotapInfo: IInstrumentsSysmotapInfo, processInfo: IInstrumentsSysmotapProcessesInfo) {
        
    }
    
    func opengl(info: IInstrumentsOpenglInfo) {
        var item = LandMarkItem()
        item.x = gpu.items.count
        #warning("TEST CODE")
        item.y = .random(in: 0 ..< 100)
        gpu.items.append(item)
    }
}

extension HomepageService {
    func start(_ device: IDevice) -> Bool {
        return serviceGroup.start(device)
    }
    
    func autoRequest() {
        serviceGroup.autoRequest()
    }
    
    func stop() {
        serviceGroup.stopRequest()
    }
}
