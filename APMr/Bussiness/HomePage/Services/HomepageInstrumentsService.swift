//
//  HomepageInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa

struct HomepageChartModel: Identifiable {
    var id: String { serviceName.rawValue }
    var items: [LandMarkItem] = []
    
    var title: String
    var serviceName: IInstrumentsServiceName
}

class HomepageInstrumentsService: NSObject {
    public weak var root: HomepageService? = nil
    
    public var sysmontap = HomepageChartModel(title: "Sysmontap" ,serviceName: .sysmontap) {
        didSet {
            root?.objectWillChange.send()
        }
    }
    
    public var opengl = HomepageChartModel(title: "Opengl" ,serviceName: .opengl) {
        didSet {
            root?.objectWillChange.send()
        }
    }
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let group = IInstrumentsServiceGroup()
        group.config(types: [.sysmontap, .opengl, .processcontrol])
        group.delegate = self
        return group
    }()
    
    private var selectPid: UInt32 = 0
}


extension HomepageInstrumentsService: IInstrumentsServiceGroupDelegate {
    func sysmontap(sysmotapInfo: IInstrumentsSysmotapInfo, processInfo: IInstrumentsSysmotapProcessesInfo) {
        guard selectPid != 0 else {
            return
        }
        
        let pid = Int64(selectPid)
        
        let item = processInfo.Processes.first { value in
           return value.key == pid
        }
        
        if let item = item,
           let arr = item.value as? [Any],
           let y = arr[1] as? CGFloat {
            let x = sysmontap.items.count
            var landmark = LandMarkItem()
            landmark.x = x
            landmark.y = y
            sysmontap.items.append(landmark)
            
            root?.objectWillChange.send()
        }
    }
    
    func opengl(info: IInstrumentsOpenglInfo) {

    }
    
    func launch(pid: UInt32) {
        selectPid = pid
        
        if let client: IInstrumentsSysmontap = serviceGroup.client(.sysmontap) {
            client.register(.setConfig)
            client.register(.start)
        }
        
    }
}

extension HomepageInstrumentsService {
    func launch(app: IInstproxyAppInfo) {
        guard let processControl: IInstrumentsProcesscontrol = serviceGroup.client(.processcontrol) else {
            return
        }
        
        processControl.register(.launch(bundleId: app.bundleId))
    }
}

extension HomepageInstrumentsService {
    func start(_ device: IDevice) {
        DispatchQueue.global().async {
            self.serviceGroup.start(device)
        }
    }
    
    func autoRequest() {
        serviceGroup.autoRequest()
    }
    
    func stop() {
        serviceGroup.stopRequest()
    }
}
