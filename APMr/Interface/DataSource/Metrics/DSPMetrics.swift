//
//  DSPMetrics.swift
//  APMr
//
//  Created by 任玉乾 on 2023/6/27.
//

import Foundation

class DSPMetrics: NSObject, ObservableObject {
    private lazy var diagnostics = ALockAction<IDiagnosticsRelay>()
    
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
    
    private(set) lazy var syncModel = M()
    private lazy var monitor = Monitor()
    
    private var monitorClosure: ((Bool) -> Void)? = nil
    private var sampleClosure: ((S) -> Void)? = nil
}

extension DSPMetrics {
    public func reset() {
        diagnostics.clean()
        serviceGroup.stop()
        monitor = Monitor()
        syncModel.reset()
    }
    
    public func link(_ phone: IDevice.P, _ comlete: @escaping (Bool) -> Void) {
        guard let device = IDevice(phone) else {
            comlete(false)
            return
        }
        self.reset()
        DispatchQueue.global().async {
            if self.serviceGroup.start(device),
               self.diagnostics.build(device) {
                comlete(true)
                return
            }
            self.serviceGroup.stop()
            comlete(false)
        }
    }
    
    public func monitor(app: IApp, _ closure: @escaping (Bool) -> Void) {
        if let client: IInstruments.Processcontrol = serviceGroup.client(.processcontrol) {
            monitorClosure = closure
            client.launch(bundle: app.bundleId)
            monitor.type = .app(app)
        } else {
            closure(false)
        }
    }
    
    public func monitor(pid: PID) {
        self.monitor.type = .pid(pid)
        self.monitor.result = .pid(pid)
        self.register()
    }
    
    public func sample(_ closure: @escaping (_ state: DSPMetrics.S) -> Void) {
        self.sampleClosure = closure
        
        if let analysis = diagnostics.instance?.analysis {
            syncModel.diagnostic.voltage = (analysis["Voltage"] as? CGFloat ?? 0) / 1000
            syncModel.diagnostic.battery = (analysis["CurrentCapacity"] as? CGFloat ?? 0)
            syncModel.diagnostic.temperature = (analysis["Temperature"] as? CGFloat ?? 0) / 100
            if let amperage = analysis["InstantAmperage"] as? UInt64, (amperage >> 63) == 0x1 {
                // https://github.com/dkw72n/idb/blob/c0789be034bbf2890aa6044a27d74938a646898d/app.py
                syncModel.diagnostic.amperage = CGFloat(UInt64.max - amperage) + 1
            }
        } else {
            closure(.invalid)
            return
        }
        
        if let pid = monitorPid,
           let network: IInstruments.NetworkStatistics = serviceGroup.client(.networkStatistics) {
            network.sample(pids: [pid])
        } else {
            closure(.invalid)
        }
    }
}

extension DSPMetrics {
    private func register() {
        if let client: IInstruments.Sysmontap = serviceGroup.client(.sysmontap) {
            client.setConfig()
            client.start()
        }
        
        if let opengl: IInstruments.Opengl = serviceGroup.client(.opengl) {
            opengl.start()
        }
    }
    
    private var monitorPid: PID? {
        switch self.monitor.result {
            case .pid(let pid):
                return pid
                
            default:
                return nil
        }
    }
}

extension DSPMetrics: IInstrumentsProcesscontrolDelegate {
    func launched(pid: PID) {
        self.monitor.result = .pid(pid)
        self.register()
        self.monitorClosure?(true)
        self.monitorClosure = nil
    }
}

extension DSPMetrics: IInstrumentsSysmontapDelegate {
    func sysmotap(model: IInstruments.Sysmontap.Model) {
        if let system = model.SystemCPUUsage {
            syncModel.cpu.total = CGFloat(system.CPU_TotalLoad) / CGFloat(model.CPUCount)
        }
    }
    
    func process(model: IInstruments.Sysmontap.ProcessesModel) {
        guard let monitorPid = monitorPid,
              let model = model.processModel(pid: Int64(monitorPid)) else {
            return
        }
        
        
        syncModel.cpu.process = model.cpuUsage
        
        syncModel.memory.memory = model.physFootprint.MB
        syncModel.memory.resident = model.physFootprint.MB
        syncModel.memory.vm = model.memVirtualSize.GB
        
        let current = Date().timeIntervalSince1970
        let lastR = syncModel.io.read
        let lastW = syncModel.io.write
        syncModel.io.read = model.diskBytesRead.MB
        syncModel.io.write = model.diskBytesWritten.MB
        
        syncModel.io.readDelta = (syncModel.io.read - lastR)
        syncModel.io.writeDelta = (syncModel.io.write - lastW)
    }
}

extension DSPMetrics: IInstrumentsOpenglDelegate {
    func sampling(model: IInstruments.Opengl.Model) {
        syncModel.gpu.device = CGFloat(model.DeviceUtilization)
        syncModel.gpu.renderer = CGFloat(model.RendererUtilization)
        syncModel.gpu.tiler = CGFloat(model.TilerUtilization)
        
        syncModel.fps.fps = model.CoreAnimationFramesPerSecond
    }
}

extension DSPMetrics: IInstrumentsNetworkStatisticsDelegate {
    func process(modelMap: [PID : IInstruments.NetworkStatistics.Model]) {
        guard let pid = monitorPid,
              let model = modelMap[pid] else {
            sampleClosure?(.invalid)
            return
        }
        
        syncModel.network.down = model.net_rx_bytes.MB
        syncModel.network.up = model.net_tx_bytes.MB
        syncModel.network.downDelta = model.net_rx_bytes_delta.MB
        syncModel.network.upDelta = model.net_tx_bytes_delta.MB
        
        sampleClosure?(.success(syncModel))
    }
}


