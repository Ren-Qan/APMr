//
//  PerformanceInstrumentsService.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import Combine
import LibMobileDevice

class PerformanceInstrumentsService: NSObject, ObservableObject {
    // MARK: - Public
    
    @Published private(set) var summary = Summary()
    
    @Published private(set) var monitorPid: PID = 0
    
    @Published var isShowPerformanceSummary = false
    
    @Published var isMonitoringPerformance = false
    
    @Published var isLaunchingApp = false
    
    @Published var xAxisPageCount = 100
    
    public lazy var pCM: PerformanceChartModel = {
        let model = PerformanceChartModel()
        model.reset(cSPI)
        return model
    }()
    
    // MARK: - Private
    
    private lazy var operationQ = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private lazy var serviceGroup: IInstrumentsServiceGroup = {
        let sysmontap = IInstruments.Sysmontap()
        sysmontap.delegate = self
        
        let opengl = IInstruments.Opengl()
        opengl.delegate = self
        
        let process = IInstruments.Processcontrol()
        process.delegate = self
        
        let net = IInstruments.NetworkStatistics()
        net.delegate = self
        
        let group = IInstrumentsServiceGroup()
        group.config([sysmontap, opengl, process, net])
        return group
    }()
        
    private var timer: Timer?
        
    private var currentSeconds: Double = 1
    
    private var cSPI = PerformanceIndicator()
    
    private var lockdown: ILockdown?
    
    private var diagnostics: IDiagnosticsRelay?
        
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Public API

extension PerformanceInstrumentsService {
    public func launch(app: IApp) {
        isLaunchingApp = true
        guard let processControl: IInstruments.Processcontrol = serviceGroup.client(.processcontrol) else {
            isLaunchingApp = false
            return
        }
        processControl.launch(bundle: app.bundleId)
    }
}

// MARK: - Public Service Setup Functions

extension PerformanceInstrumentsService {
    public func start(_ device: DeviceItem,
                      _ complete: ((Bool, PerformanceInstrumentsService) -> Void)? = nil) {
        DispatchQueue.global().async {
            var success = false
            
            if let iDevice = IDevice(device) {
                success = self.serviceGroup.start(iDevice)
                if let lockdown = ILockdown(iDevice) {
                    self.lockdown = lockdown
                    self.diagnostics = IDiagnosticsRelay(iDevice, lockdown)
                }
            }
            self.resetData()
            complete?(success, self)
        }
    }
            
    public func stopService() {
        timer?.invalidate()
        timer = nil
        serviceGroup.stop()
        monitorPid = 0
        currentSeconds = 1
        isLaunchingApp = false
        isMonitoringPerformance = false
        diagnostics = nil
        lockdown = nil
        operationQ.cancelAllOperations()
    }
    
    public func highlight(start: Int, end: Int, isDragging: Bool) {
        let count = pCM.count
        if isDragging {
            func correct(_ x: Int) -> Int {
                let baseX = count - xAxisPageCount < 0 ? 0 : count - xAxisPageCount
                if x < baseX {
                    return baseX
                }
                
                if x >= count - 1 {
                    return count - 1
                }
                
                return x
            }
            
            let s = correct(start)
            let e = correct(end)
            
            if summary.highlightState.start != s || summary.highlightState.end != e {
                summary.set(startX: s, endX: e)
            }
        } else {
            if start < 0 {
                return
            }
            let s = start >= count ? count - 1 : start
            if summary.highlightState.start != s || summary.highlightState.end != s {
                summary.set(startX: s, endX: s)
            }
        }
    }
}

// MARK: - Private

extension PerformanceInstrumentsService {
    private func monitor(_ pid: PID) {
        monitorPid = pid
        if pid != 0 {
            isMonitoringPerformance = true
            isLaunchingApp = false
            register()
            
            timer?.invalidate()
            timer = nil
            timer = Timer(timeInterval: 1,
                          repeats: true,
                          block: { [weak self] _ in
                self?.sample()
            })
            timer?.fire()
            RunLoop.main.add(timer!, forMode: .common)
        }
    }
    
    private func sample() {
        self.operationQ.addOperation { [weak self] in
            self?.send()
            self?.record()
        }
    }
    
    private func register() {
        if let client: IInstruments.Sysmontap = serviceGroup.client(.sysmontap) {
            client.setConfig()
            client.start()
        }
        
        if let opengl: IInstruments.Opengl = serviceGroup.client(.opengl) {
            opengl.start()
        }
    }
    
    private func send() {
        if let network: IInstruments.NetworkStatistics = serviceGroup.client(.networkStatistics) {
            network.sample(pids: [monitorPid])
        }
        
        if let diagnostics = diagnostics?.analysis {
            cDiagnostic(diagnostics)
        }
    }
        
    private func record() {
        summary.add(cSPI)
        pCM.add(cSPI, xAxisPageCount)
        
        currentSeconds += 1
        cSPI.seconds = CGFloat(currentSeconds)
        
        DispatchQueue.main.async {
            self.pCM.models.forEach { model in
                if model.visiable {
                    model.objectWillChange.send()
                }
            }
        }
    }
    
    private func resetData() {
        cSPI = PerformanceIndicator()
        currentSeconds = 1
        pCM.reset(cSPI)
        summary.reset()
    }
}

extension PerformanceInstrumentsService: IInstrumentsProcesscontrolDelegate {
    func outputReceived(_ msg: String) {

    }
    
    func launch(pid: PID) {
        monitor(pid)
    }
}

extension PerformanceInstrumentsService: IInstrumentsSysmontapDelegate {
    func sysmotap(model: IInstruments.Sysmontap.Model) {
        cTotalCPU(model)
    }
    
    func process(model: IInstruments.Sysmontap.ProcessesModel) {
        guard let process = model.processModel(pid: Int64(monitorPid)) else {
            return
        }
        cProcessCPU(process)
        cMemory(process)
        cIO(process)
    }
}

extension PerformanceInstrumentsService: IInstrumentsOpenglDelegate {
    func sampling(model: IInstruments.Opengl.Model) {
        cGPU(model)
        cFPS(model)
    }
}

extension PerformanceInstrumentsService: IInstrumentsNetworkStatisticsDelegate {
    func process(modelMap: [UInt32: IInstruments.NetworkStatistics.Model]) {
        guard monitorPid != 0, let model = modelMap[monitorPid] else {
            return
        }
        cNetwork(model)
    }
}

// MARK: - 模型解析

extension PerformanceInstrumentsService {
    private func cTotalCPU(_ sysmotapInfo: IInstruments.Sysmontap.Model) {
        var totalUsage: CGFloat = 0
        if let system = sysmotapInfo.SystemCPUUsage {
            // mark Usage = SystemCPUUsage.CPU_TotalLoad / EnabledCPUs - https://github.com/dkw72n/idb
            totalUsage = CGFloat(system.CPU_TotalLoad) / CGFloat(sysmotapInfo.CPUCount)
        }
        cSPI.cpu.total = totalUsage
    }
    
    private func cProcessCPU(_ process: IInstruments.Sysmontap.SystemProcessesModel) {
        cSPI.cpu.process = process.cpuUsage
    }
    
    private func cGPU(_ info: IInstruments.Opengl.Model) {
        let item = cSPI.gpu
        item.device = CGFloat(info.DeviceUtilization)
        item.renderer = CGFloat(info.RendererUtilization)
        item.tiler = CGFloat(info.TilerUtilization)
    }
    
    private func cMemory(_ process: IInstruments.Sysmontap.SystemProcessesModel) {
        let item = cSPI.memory
        item.memory = process.physFootprint.MB
        item.resident = process.memResidentSize.MB
        item.vm = process.memVirtualSize.GB
    }
    
    private func cIO(_ process: IInstruments.Sysmontap.SystemProcessesModel) {
        let item = cSPI.io
        let lastR = cSPI.io.read
        let lastW = cSPI.io.write
        item.read = process.diskBytesRead.MB
        item.write = process.diskBytesWritten.MB
        item.readDelta = item.read - lastR
        item.writeDelta = item.write - lastW
    }
    
    private func cFPS(_ info: IInstruments.Opengl.Model) {
        let item = cSPI.fps
        item.fps = info.CoreAnimationFramesPerSecond
    }
    
    private func cNetwork(_ info: IInstruments.NetworkStatistics.Model) {
        let item = cSPI.network
        item.down = info.net_rx_bytes.MB
        item.up = info.net_tx_bytes.MB
        item.downDelta = info.net_rx_bytes_delta.MB
        item.upDelta = info.net_tx_bytes_delta.MB
    }
    
    private func cDiagnostic(_ dic: [String: Any]) {
        let item = cSPI.diagnostic
        item.voltage = (dic["Voltage"] as? CGFloat ?? 0) / 1000
        item.battery = (dic["CurrentCapacity"] as? CGFloat ?? 0)
        item.temperature = (dic["Temperature"] as? CGFloat ?? 0) / 100
        if let amperage = dic["InstantAmperage"] as? UInt64, (amperage >> 63) == 0x1 {
            // 参考 https://github.com/dkw72n/idb/blob/c0789be034bbf2890aa6044a27d74938a646898d/app.py
            item.amperage = CGFloat(UInt64.max - amperage) + 1
        }
    }
}

// MARK: - TEST FUNC

extension PerformanceInstrumentsService {
    func insertTestData(count: Int) {
        func randomCPCM() {
            cSPI.cpu.process = .random(in: 0 ... 100)
            cSPI.cpu.total = .random(in: 0 ... 100)
            
            cSPI.gpu.renderer = .random(in: 0 ... 100)
            cSPI.gpu.device = .random(in: 0 ... 100)
            cSPI.gpu.tiler = .random(in: 0 ... 100)
            
            cSPI.fps.fps = .random(in: 0 ... 120)
            
            cSPI.io.readDelta = .random(in: 0 ... 40)
            cSPI.io.writeDelta = .random(in: 0 ... 40)
            
            cSPI.network.downDelta = .random(in: 0 ... 100)
            cSPI.network.upDelta = .random(in: 0 ... 100)
            
            cSPI.diagnostic.amperage = .random(in: 0 ... 40)
            cSPI.diagnostic.battery = .random(in: 0 ... 100)
            cSPI.diagnostic.voltage = .random(in: 0 ... 20)
            cSPI.diagnostic.temperature = .random(in: 10 ... 44)
            
            cSPI.memory.memory = .random(in: 0 ... 500)
            cSPI.memory.resident = .random(in: 0 ... 500)
            cSPI.memory.vm = .random(in: 0 ... 500)
        }
        
        DispatchQueue.global().async {
            let time = Date().timeIntervalSince1970
            (0 ..< count).forEach { i in
                self.operationQ.addOperation { [weak self] in
                    randomCPCM()
                    self?.record()
                    if i == count - 1 {
                        debugPrint("插入\(count)条数据 耗时: \(Date().timeIntervalSince1970 - time)")
                    }
                }
            }
        }
    }
}
