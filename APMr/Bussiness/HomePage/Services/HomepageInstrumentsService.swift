//
//  HomepageInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import Combine

struct HomepageBarCharItem: PerformanceCoordinateViewMarkProtocol {
    var x: Int
    
    var y: Int
    
    var tips: String
    
    var id: Int {
        return x
    }
}

struct HomepageBarChartModel: Identifiable {
    var title: String
    var datas: [HomepageBarCharItem] = []
    
    var id: String { title }
}

class HomepageInstrumentsService: NSObject, ObservableObject {    
    @Published public var cpu = HomepageBarChartModel(title: "CPU")
    
    @Published public var gpu = HomepageBarChartModel(title: "GPU")
    
    @Published public var isRunningService = false
    @Published public var isLinkingService = false
    
    //    @Published public var memory = HomepageChartModel(title: "Memory")
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let group = IInstrumentsServiceGroup()
        group.config(types: [.sysmontap, .opengl, .processcontrol])
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
        isLinkingService = true
        processControl.send(.launch(bundleId: app.bundleId))
    }
}

// MARK: - Public Service Setup Functions -
extension HomepageInstrumentsService {
    public func start(_ device: DeviceItem) {
        DispatchQueue.global().async {
            if let iDevice = IDevice(device) {
                self.serviceGroup.start(iDevice)
            }
        }
    }
    
    public func request() {
        serviceGroup.request()
    }
    
    public func autoRequest() {
        serviceGroup.autoRequest(0.25)
    }
    
    public func stopService() {
        serviceGroup.stop()
        isLinkingService = false
        isRunningService = false
    }
}

// MARK: - Privce -

extension HomepageInstrumentsService {
    private func resetData() {
        cpu.datas = []
        gpu.datas = []
    }
}

// MARK: - IInstrumentsServiceGroupDelegate -
extension HomepageInstrumentsService: IInstrumentsServiceGroupDelegate {
    func receiveNil() {
        stopService()
        isLinkingService = false
    }
    
    func sysmontap(sysmotapInfo: IInstrumentsSysmotapInfo, processInfo: IInstrumentsSysmotapProcessesInfo) {
        
    }
    
    func opengl(info: IInstrumentsOpenglInfo) {
        
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
        
        resetData()
        isRunningService = true
        isLinkingService = false
    }
}


