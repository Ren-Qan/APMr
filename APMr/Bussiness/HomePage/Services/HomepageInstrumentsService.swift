//
//  HomepageInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import Combine
import LibMobileDevice

class HomepageInstrumentsService: NSObject, ObservableObject {    
    @Published public var cpu = HomepageBarChartModel(title: "CPU", yMax: 10000)
    @Published public var gpu = HomepageBarChartModel(title: "GPU", yMax: 10000)
    @Published public var memory = HomepageLineChartModel(title: "Memory")
    
    @Published public var isRunningService = false
    @Published public var isLinkingService = false
    @Published public var selectPid: UInt32 = 0
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let group = IInstrumentsServiceGroup()
        group.config(types: [.sysmontap, .opengl, .processcontrol, .networkStatistics])
        group.delegate = self
        return group
    }()
    
    private var receiceNilCount = 0
    
    private var timer: Timer? = nil
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Public API -
extension HomepageInstrumentsService {
    public func launch(app: IInstproxyAppInfo) {
        guard let processControl: IInstrumentsProcesscontrol = serviceGroup.client(.processcontrol) else {
            isLinkingService = false
            return
        }
        processControl.send(.launch(bundleId: app.bundleId))
    }
}

// MARK: - Public Service Setup Functions -
extension HomepageInstrumentsService {
    public func start(_ device: DeviceItem, _ complete: ((Bool, HomepageInstrumentsService) -> Void)? = nil) {
        DispatchQueue.global().async {
            self.isLinkingService = true
            var success = false
            if let iDevice = IDevice(device) {
                success = self.serviceGroup.start(iDevice)
            }
            complete?(success, self)
        }
    }
    
    public func request() {
        serviceGroup.request()
    }
    
    public func autoRequest() {
//        serviceGroup.autoRequest(0.25)
        timer?.invalidate()
        timer = nil
        
        timer = Timer(timeInterval: 0.25, repeats: true, block: { [weak self] _ in
            self?.requestNetData()
            self?.serviceGroup.request()
        })
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    public func stopService() {
        serviceGroup.stop()
        isLinkingService = false
        isRunningService = false
        selectPid = 0
    }
}

// MARK: - Privce -

extension HomepageInstrumentsService {
    private func requestNetData() {
        guard selectPid != 0 else {
            return
        }
        
        if let client: IInstrumentsNetworkStatistics = serviceGroup.client(.networkStatistics) {
            client.send(.sample(pids: [selectPid]))
//            client.send(.start(pid: selectPid))
        }
    }
    
    private func resetData() {
        cpu.datas = []
        gpu.datas = []
    }
}

// MARK: - IInstrumentsServiceGroupDelegate -
extension HomepageInstrumentsService: IInstrumentsServiceGroupDelegate {
    func receive(response: DTXReceiveObject?) {
        if response == nil {
            receiceNilCount += 1
        } else {
            receiceNilCount = 0
        }
        
        if receiceNilCount == 10 {
            stopService()
        }
    }
    
    func sysmontap(sysmotapInfo: IInstrumentsSysmotapInfo, processInfo: IInstrumentsSysmotapProcessesInfo) {
        guard selectPid != 0 else {
            return
        }
        
        if let info = processInfo.Processes[Int64(selectPid)] as? [Any] {
            if let cpuUse = info[0] as? CGFloat {
                let item = HomepageBarCharItem(x: cpu.datas.count,
                                               y: Int(cpuUse * 100),
                                               tips: "cpuUse: \(String(format: "%.2f", cpuUse))%")
                cpu.datas.append(item)
            }
            
            var newMaxY = memory.yMax
            
            if let res = info[5] as? Int,
               let anon = info[6] as? Int {
                func item(y: Int, tips: String, xKey: String, yKey: String) -> HomepageLineCharItem {
                    
                    if y > newMaxY {
                        newMaxY = y
                    }
                    
                    let x = memory.datas.count / 2
                    let Item = HomepageLineCharItem(x: x,
                                                    y: y,
                                                    tips: tips,
                                                    xAxisKey: xKey,
                                                    yAxisKey: yKey)
                    return Item
                }
                
                let resItem = item(y: res, tips: "memResidentSize:\(res)", xKey: "res_x", yKey: "res_y")
                let anonItem = item(y: anon, tips: "memAnon:\(anon)", xKey: "anon_x", yKey: "anon_y")
                memory.yMax = newMaxY
                memory.datas.append(contentsOf: [resItem, anonItem])
            }
        }
    }
    
    func opengl(info: IInstrumentsOpenglInfo) {
        guard selectPid != 0 else {
            return
        }
        
        let gpuUse = CGFloat(info.DeviceUtilization + info.TilerUtilization + info.RendererUtilization) / 3.0
        let item = HomepageBarCharItem(x: gpu.datas.count,
                                       y: Int(gpuUse * 100),
                                       tips: "gpuUse: \(String(format: "%.2f", gpuUse))%")
        gpu.datas.append(item)
    }
    
    func networkStatistics(info: [Int64 : IInstrumentsNetworkStatisticsModel]) {
        
    }
    
    func launch(pid: UInt32) {
        selectPid = pid
        
        if let sysmontap: IInstrumentsSysmontap = serviceGroup.client(.sysmontap) {
            sysmontap.register(.setConfig)
            sysmontap.register(.start)
        }
        
//        if let opengl: IInstrumentsOpengl = serviceGroup.client(.opengl) {
//            opengl.register(.startSampling)
//        }
        
//        if let network: IInstrumentsNetworking = serviceGroup.client(.networking) {
//            network.register(.replayLastRecordedSession)
//            network.register(.startMonitoring)
//        }
  
        
//        if let engery: IInstrumentsNetworkStatistics = serviceGroup.client(.networkStatistics) {
//            engery.register(.start(pid: pid))
//            engery.register(.sample(pid: pid))
//        }
        
        
        resetData()
        isRunningService = true
        isLinkingService = false
    }
}


