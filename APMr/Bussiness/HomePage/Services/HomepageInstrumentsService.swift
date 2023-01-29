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
    @Published var isMonitoringPerformance = false
    
    @Published var isLaunchingApp = false
    
    @Published var pDatas: [PerformanceIndicator] = []
    
    @Published private(set) var monitorPid: UInt32 = 0
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let group = IInstrumentsServiceGroup()
        group.delegate = self
        group.config([
            .sysmontap,
            .opengl,
            .processcontrol,
            .networkStatistics,
            .energy
        ])
        return group
    }()
    
    private var timer: Timer? = nil
    
    private var receiceSeriesNilCount = 0
    
    private var currentSeconds = 1
    
    private var cSPI = PerformanceIndicator()
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Public API -
extension HomepageInstrumentsService {
    public func launch(app: IInstproxyAppInfo) {
        isLaunchingApp = true
        guard let processControl: IInstrumentsProcesscontrol = serviceGroup.client(.processcontrol) else {
            isLaunchingApp = false
            return
        }
        processControl.send(.launch(bundleId: app.bundleId))
    }
}

// MARK: - Public Service Setup Functions -
extension HomepageInstrumentsService {
    public func start(_ device: DeviceItem,
                      _ complete: ((Bool, HomepageInstrumentsService) -> Void)? = nil) {
        DispatchQueue.global().async {
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
        timer?.invalidate()
        timer = nil
                
        var count = 0
        let sampleTimer = 0.125
        let cycle = Int(1 / sampleTimer)
        timer = Timer(timeInterval: sampleTimer,
                      repeats: true,
                      block: { [weak self] _ in
            self?.request()
            if count % cycle == 0 {
                self?.send()
            }
            
            if count % cycle == cycle - 1 {
                self?.dataRecord()
            }
            
            count += 1
        })
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    public func stopService() {
        timer?.invalidate()
        timer = nil
        serviceGroup.stop()
        monitorPid = 0
        currentSeconds = 1
        receiceSeriesNilCount = 0
        isLaunchingApp = false
        isMonitoringPerformance = false
    }
}

extension HomepageInstrumentsService {
    private func register() {
        if let sysmontap: IInstrumentsSysmontap = serviceGroup.client(.sysmontap) {
            sysmontap.register(.setConfig)
            sysmontap.register(.start)
        }
        
        if let opengl: IInstrumentsOpengl = serviceGroup.client(.opengl) {
            opengl.register(.startSampling)
        }
    }
    
    private func send() {
        if let energy: IInstrumentsEnergy = serviceGroup.client(.energy) {
            energy.register(.start(pids: [monitorPid]))
            energy.register(.sample(pids: [monitorPid]))
        }
        
        if let network: IInstrumentsNetworkStatistics = serviceGroup.client(.networkStatistics) {
            network.send(.start(pids: [monitorPid]))
            network.send(.sample(pids: [monitorPid]))
        }
    }
    
    private func dataRecord() {
        print("第\(currentSeconds)秒-数据同步")
        
        pDatas.append(cSPI)
        cSPI = PerformanceIndicator()
        
        currentSeconds += 1
    }
}

// MARK: - IInstrumentsServiceGroupDelegate -
extension HomepageInstrumentsService: IInstrumentsServiceGroupDelegate {
    func receive(response: DTXReceiveObject?) {
        if response == nil {
            receiceSeriesNilCount += 1
        } else {
            receiceSeriesNilCount = 0
        }
        
        let MAX_ERROR_COUNT = 10
        if receiceSeriesNilCount == MAX_ERROR_COUNT {
            stopService()
        }
    }
        
    func launch(pid: UInt32) {
        monitorPid = pid
        if pid != 0 {
            isMonitoringPerformance = true
            isLaunchingApp = false
            register()
        }
    }
    
    func sysmontap(sysmotapInfo: IInstrumentsSysmotapInfo,
                   processInfo: IInstrumentsSysmotapProcessesInfo) {
        print("cpu")
        
        var totalUsage: CGFloat = 0
        if let system = sysmotapInfo.SystemCPUUsage {
            // mark Usage = SystemCPUUsage.CPU_TotalLoad / EnabledCPUs - https://github.com/dkw72n/idb
            totalUsage = CGFloat(system.CPU_TotalLoad) / CGFloat(sysmotapInfo.CPUCount)
        }

        var processUsage: CGFloat = 0
        if let process = processInfo.processInfo(pid: Int64(monitorPid)) {
            processUsage = process.cpuUsage
        }
        
        let item = PerformanceCPUIndicator(seconds: currentSeconds,
                                           process: processUsage,
                                           total: totalUsage)
        cSPI.cpu = item
    }
    
    func opengl(info: IInstrumentsOpenglInfo) {
        print("opengl")
    }
    
    func networkStatistics(info: [Int64 : IInstrumentsNetworkStatisticsModel]) {
        print("network")
    }
    
    func energy(info: [Int64 : IInstrumentsEnergyModel]) {
        print("energy")
    }
}


