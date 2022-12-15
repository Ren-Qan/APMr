//
//  HomepageInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import Combine

struct HomepageChartModel: Identifiable {
    var id: String { title }
    var title: String
    
    
}

class HomepageInstrumentsService: NSObject, ObservableObject {    
    @Published public var cpu = HomepageChartModel(title: "CPU")
        
    @Published public var gpu = HomepageChartModel(title: "GPU")
    
    @Published public var memory = HomepageChartModel(title: "Memory")
    
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
    
    public func stopService() {
        serviceGroup.stop()
    }
}

// MARK: - Privce -

private extension HomepageInstrumentsService {
    
}

// MARK: - IInstrumentsServiceGroupDelegate -
extension HomepageInstrumentsService: IInstrumentsServiceGroupDelegate {
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
    }
}


