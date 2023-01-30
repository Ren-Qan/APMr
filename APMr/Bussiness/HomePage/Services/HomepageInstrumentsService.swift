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
        ])
        return group
    }()
    
    private var timer: Timer? = nil
    
    private var receiceSeriesNilCount = 0
    
    private var currentSeconds = 1
    
    private var cSPI = PerformanceIndicator()
    
    private var lockdown: ILockdown? = nil
    private var diagnostics: IDiagnosticsRelay? = nil
    
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
                if let lockdown = ILockdown(iDevice) {
                    self.lockdown = lockdown
                    self.diagnostics = IDiagnosticsRelay(iDevice, lockdown)
                }
                
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
        diagnostics = nil
        lockdown = nil
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
        if let network: IInstrumentsNetworkStatistics = serviceGroup.client(.networkStatistics) {
            network.send(.start(pids: [monitorPid]))
            network.send(.sample(pids: [monitorPid]))
        }
        
        if let diagnostics = diagnostics?.analysis {
            cDiagnostic(diagnostics)
        }
    }
    
    private func dataRecord() {
        print("第\(currentSeconds)秒-数据同步")
        pDatas.append(cSPI)
        currentSeconds += 1
        cSPI = PerformanceIndicator(seconds: CGFloat(currentSeconds))
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
        guard let process = processInfo.processInfo(pid: Int64(monitorPid)) else {
            return
        }
        
        cCPU(sysmotapInfo, process)
        cMemory(process)
        cIO(process)
    }
    
    func opengl(info: IInstrumentsOpenglInfo) {
        cGPU(info)
        cFPS(info)
    }
    
    func networkStatistics(info: [Int64 : IInstrumentsNetworkStatisticsModel]) {
        guard monitorPid != 0, let model = info[Int64(monitorPid)] else {
            return
        }
        cNetwork(model)
    }
}

// 模型解析
extension HomepageInstrumentsService {
    private func cCPU(_ sysmotapInfo: IInstrumentsSysmotapInfo,
                      _ process: IInstrumentsSysmotapSystemProcessesModel) {
        var totalUsage: CGFloat = 0
        if let system = sysmotapInfo.SystemCPUUsage {
            // mark Usage = SystemCPUUsage.CPU_TotalLoad / EnabledCPUs - https://github.com/dkw72n/idb
            totalUsage = CGFloat(system.CPU_TotalLoad) / CGFloat(sysmotapInfo.CPUCount)
        }
        
        let item = PCPUIndicator(process: process.cpuUsage,
                                 total: totalUsage)
        cSPI.cpu = item
    }
    
    private func cGPU(_ info: IInstrumentsOpenglInfo) {
        var item = PGPUIndicator()
        item.divice = CGFloat(info.DeviceUtilization) / 100
        item.renderer = CGFloat(info.RendererUtilization) / 100
        item.tiler = CGFloat(info.TilerUtilization) / 100
        cSPI.gpu = item
    }
        
    private func cMemory(_ process: IInstrumentsSysmotapSystemProcessesModel) {
        var item = PMemoryIndicator()
        item.memory = process.physFootprint
        item.resident = process.memResidentSize
        item.vm = process.memVirtualSize
        cSPI.memory = item
    }
    
    private func cIO(_ process: IInstrumentsSysmotapSystemProcessesModel) {
        var item = PIOIndicator()
        item.read = CGFloat(Double(process.diskBytesRead) / (1024 * 1024 * 8))
        item.write = CGFloat(Double(process.diskBytesWritten) / (1024 * 1024 * 8))
        cSPI.io = item
    }
    
    private func cFPS(_ info: IInstrumentsOpenglInfo) {
        var item = PFPSIndicator()
        item.fps = info.CoreAnimationFramesPerSecond
        cSPI.fps = item
    }
    
    private func cNetwork(_ info: IInstrumentsNetworkStatisticsModel) {
        var item = PNetworkIndicator()
        item.down = CGFloat(info.net_rx_bytes)
        item.up = CGFloat(info.net_tx_bytes)
        cSPI.network = item
    }
    
    private func cDiagnostic(_ dic: [String : Any]) {
        var item = PDiagnosticIndicator()
        item.voltage = (dic["Voltage"] as? CGFloat ?? 0) / 1000
        item.battery = (dic["CurrentCapacity"] as? CGFloat ?? 0) / 100
        item.temperature = (dic["Temperature"] as? CGFloat ?? 0) / 100
        if let amperage = dic["InstantAmperage"] as? UInt64 {
            // 参考 https://github.com/dkw72n/idb/blob/c0789be034bbf2890aa6044a27d74938a646898d/app.py
            item.amperage = CGFloat(UInt64.max - amperage) + 1
        }
        cSPI.diagnostic = item
    }
}
