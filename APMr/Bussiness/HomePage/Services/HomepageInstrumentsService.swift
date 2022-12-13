//
//  HomepageInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import Combine

struct HomepageChartModel: Identifiable {
    var id: String { serviceName.rawValue }
    var items: [LandMarkItem] = []
    
    var title: String
    var serviceName: IInstrumentsServiceName
}

class HomepageInstrumentsService: NSObject, ObservableObject {    
    @Published public var sysmontap = HomepageChartModel(title: "Sysmontap" ,serviceName: .sysmontap)
    
    @Published public var opengl = HomepageChartModel(title: "Opengl" ,serviceName: .opengl)
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let group = IInstrumentsServiceGroup()
        group.config(types: [.sysmontap, .opengl, .processcontrol, .gpu])
        group.delegate = self
        return group
    }()
    
    private var selectPid: UInt32 = 0
}

// MARK: - Public API -
extension HomepageInstrumentsService {
   public func launch(app: IInstproxyAppInfo) {
        guard let processControl: IInstrumentsProcesscontrol = serviceGroup.client(.processcontrol) else {
            return
        }
        
        processControl.send(.launch(bundleId: app.bundleId))
    }
}

// MARK: - Public Service Setup Functions -
extension HomepageInstrumentsService {
    public func start(_ device: IDevice) {
        DispatchQueue.global().async {
            self.serviceGroup.start(device)
        }
    }
    
    public func request() {
        serviceGroup.request()
    }
    
    public func autoRequest() {
        serviceGroup.autoRequest(0.25)
    }
}

// MARK: - Privce -

private extension HomepageInstrumentsService {
    
}

// MARK: - IInstrumentsServiceGroupDelegate -
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
        }
    }
    
    func opengl(info: IInstrumentsOpenglInfo) {
        guard selectPid != 0, info.Allocsystemmemory > 0 else {
            return
        }
        
        let x = opengl.items.count
        var landmark = LandMarkItem()
        landmark.x = x
        landmark.y = CGFloat(info.RendererUtilization + info.TilerUtilization + info.DeviceUtilization) / 3
        opengl.items.append(landmark)
    }
    
    func launch(pid: UInt32) {
        selectPid = pid
        
        if let sysmontap: IInstrumentsSysmontap = serviceGroup.client(.sysmontap) {
            sysmontap.register(.setConfig)
            sysmontap.register(.start)
        }
        
        if let opengl: IInstrumentsOpengl = serviceGroup.client(.opengl) {
            opengl.register(.startSampling)
        }
        
        
    }
}


