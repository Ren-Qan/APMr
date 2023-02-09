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
    //MARK: - Public
    
    @Published private(set) var summary = Summary()
    
    @Published private(set) var monitorPid: UInt32 = 0
    
    @Published var isMonitoringPerformance = false
    
    @Published var isLaunchingApp = false
    
    @Published var xAxisPageCount = 100
    
    public var pCM = PerformanceChartModel()
    
    //MARK: - Private
    private lazy var operationQ = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
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
    
    private var currentSeconds: Double = 0
    
    private var cSPI = PerformanceIndicator()
    
    private var lockdown: ILockdown? = nil
    
    private var diagnostics: IDiagnosticsRelay? = nil
        
    private var temHightlightX: Int = 0
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: - Public API
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

// MARK: - Public Service Setup Functions 
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

            let old = self.pCM
            let new = PerformanceChartModel()
            
            (0 ..< old.models.count).forEach { i in
                new.models[i].visiable = old.models[i].visiable
            }
            
            self.pCM = new
            self.cSPI = PerformanceIndicator()
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
            self?.operationQ.addOperation({
                self?.request()
                if count % cycle == 0 {
                    self?.send()
                }
                
                if count % cycle == cycle - 1 {
                    self?.record()
                }
                
                count += 1
            })
        })
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    public func stopService() {
        timer?.invalidate()
        timer = nil
        serviceGroup.stop()
        monitorPid = 0
        currentSeconds = 0
        receiceSeriesNilCount = 0
        isLaunchingApp = false
        isMonitoringPerformance = false
        diagnostics = nil
        lockdown = nil
        operationQ.cancelAllOperations()
    }
    
    public func highlightSelect(x: Int) {
        summary.set(temX: x)
    }
}

// MARK: - Private

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
    
    private func record() {
        debugPrint("第\(currentSeconds)秒-数据同步")
        
        let x = Int(currentSeconds)
        let count = x + 1
        
        func lm(_ y: Int) -> ChartLandmarkItem {
            ChartLandmarkItem(x: x, y: y)
        }
                
        pCM.models.forEach { model in
            var landmarks: [ChartLandmarkItem] = []
        
            switch model.type {
                case .cpu:
                    landmarks = [lm(Int(cSPI.cpu.process)),
                                 lm(Int(cSPI.cpu.total))]
                case .gpu:
                    landmarks = [lm(Int(cSPI.gpu.device)),
                                 lm(Int(cSPI.gpu.renderer)),
                                 lm(Int(cSPI.gpu.tiler))]
                case .fps:
                    landmarks = [lm(Int(cSPI.fps.fps)),
                                 lm(Int(cSPI.fps.jank)),
                                 lm(Int(cSPI.fps.bigJank)),
                                 lm(Int(cSPI.fps.stutter))]
                case .memory:
                    landmarks = [lm(Int(cSPI.memory.memory)),
                                 lm(Int(cSPI.memory.resident)),
                                 lm(Int(cSPI.memory.vm))]
                    
                case .network:
                    landmarks = [lm(Int(cSPI.network.upDelta)),
                                 lm(Int(cSPI.network.downDelta))]
                    
                case .io:
                    landmarks = [lm(Int(cSPI.io.readDelta)),
                                 lm(Int(cSPI.io.writeDelta))]
                    
                case .diagnostic:
                    landmarks = [lm(Int(cSPI.diagnostic.amperage)),
                                 lm(Int(cSPI.diagnostic.voltage)),
                                 lm(Int(cSPI.diagnostic.battery)),
                                 lm(Int(cSPI.diagnostic.temperature))]
            }
            
            var xStart = count - xAxisPageCount
            if xStart < 0 {
                xStart = 0
            }
            let xEnd = xStart + 100
            
            model.xAxis.start = xStart
            model.xAxis.end = xEnd
            
            var yMax = 10
            
            (0 ..< model.series.count).forEach { i in
                if landmarks[i].y > yMax {
                    yMax = landmarks[i].y
                }
                model.series[i].landmarks.append(landmarks[i])
            }
            
            yMax = Int(CGFloat(yMax) / 0.8)
                       
            if model.yAxis.end < yMax {
                model.yAxis.end = yMax
            }
        }
        
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
}

// MARK: - IInstrumentsServiceGroupDelegate
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

// MARK: - 模型解析
extension HomepageInstrumentsService {
    private func cCPU(_ sysmotapInfo: IInstrumentsSysmotapInfo,
                      _ process: IInstrumentsSysmotapSystemProcessesModel) {
        var totalUsage: CGFloat = 0
        if let system = sysmotapInfo.SystemCPUUsage {
            // mark Usage = SystemCPUUsage.CPU_TotalLoad / EnabledCPUs - https://github.com/dkw72n/idb
            totalUsage = CGFloat(system.CPU_TotalLoad) / CGFloat(sysmotapInfo.CPUCount)
        }
        
        cSPI.cpu.process = process.cpuUsage
        cSPI.cpu.total = totalUsage
    }
    
    private func cGPU(_ info: IInstrumentsOpenglInfo) {
        let item = cSPI.gpu
        item.device = CGFloat(info.DeviceUtilization)
        item.renderer = CGFloat(info.RendererUtilization)
        item.tiler = CGFloat(info.TilerUtilization)
    }
    
    private func cMemory(_ process: IInstrumentsSysmotapSystemProcessesModel) {
        let item = cSPI.memory
        item.memory = process.physFootprint.MB
        item.resident = process.memResidentSize.MB
        item.vm = process.memVirtualSize.GB
    }
    
    private func cIO(_ process: IInstrumentsSysmotapSystemProcessesModel) {
        let item = cSPI.io
        let lastR = cSPI.io.read
        let lastW = cSPI.io.write
        item.read = process.diskBytesRead.KB
        item.write = process.diskBytesWritten.KB
        item.readDelta = item.read - lastR
        item.writeDelta = item.write - lastW
    }
    
    private func cFPS(_ info: IInstrumentsOpenglInfo) {
        let item = cSPI.fps
        item.fps = info.CoreAnimationFramesPerSecond
    }
    
    private func cNetwork(_ info: IInstrumentsNetworkStatisticsModel) {
        let item = cSPI.network
        item.downDelta = info.net_rx_bytes_delta.KB
        item.upDelta = info.net_tx_bytes_delta.KB
    }
    
    private func cDiagnostic(_ dic: [String : Any]) {
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


// MARK: - Helper Child Service
extension HomepageInstrumentsService {
    class Summary: NSObject, ObservableObject {
        public enum HighlightState {
            case select(xAxis: Int)
            case none
            
            var x: Int? {
                switch self {
                    case .select(let x):
                        return x
                    default: return nil
                }
            }
        }
        
        @Published private(set) var highlightState: HighlightState = .none
        
        private var timer: Timer?
        private var tempHighlightX = 0
        
        deinit {
            stopSet()
        }
        
        private func start() {
            stopSet()
            
            let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] _ in
                
                
                if let x = self?.tempHighlightX {
                    if let currentX = self?.highlightState.x {
                        if currentX != x {
                            self?.highlightState = .select(xAxis: x)
                        }
                    } else {
                        self?.highlightState = .select(xAxis: x)
                    }
                }
            }
            timer.fire()
            self.timer = timer
            RunLoop.main.add(timer, forMode: .common)
        }
        
        fileprivate func set(temX: Int) {
            tempHighlightX = temX
            if timer == nil {
                start()
            }
            
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(stopSet), object: nil)
            perform(#selector(stopSet), with: nil, afterDelay: 0.1)
        }
        
        @objc private func stopSet() {
            timer?.invalidate()
            timer = nil
        }
    }
}

// MARK: - TEST FUNC
extension HomepageInstrumentsService {
    func insertTestData(count: Int) {
        func randomCPCM() {
            cSPI.cpu.process = .random(in:  0 ... 100)
            cSPI.cpu.total = .random(in: 0 ... 100)
            
            cSPI.gpu.renderer = .random(in: 0 ... 100)
            cSPI.gpu.device = .random(in: 0 ... 100)
            cSPI.gpu.tiler = .random(in: 0 ... 100)
            
            cSPI.fps.fps = .random(in: 0 ... 120)
            
            cSPI.io.readDelta = .random(in: 0 ... 40)
            cSPI.io.writeDelta = .random(in: 0 ... 40)
            
            cSPI.network.downDelta = .random(in: 0 ... 100)
            cSPI.network.upDelta = .random(in: 0 ... 100)
            
            cSPI.diagnostic.amperage = .random(in:  0 ... 40)
            cSPI.diagnostic.battery = .random(in: 0 ... 100)
            cSPI.diagnostic.voltage = .random(in: 0 ... 20)
            cSPI.diagnostic.temperature = .random(in:  10 ... 44)
            
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
                    if (i == count - 1) {
                        print("插入\(count)条数据 耗时: \(Date().timeIntervalSince1970 - time)")
                    }
                }
            }
        }
    }
}
