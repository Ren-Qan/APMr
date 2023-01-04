//
//  IInstrumentsServiceGroup.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/8.
//

import Cocoa
import LibMobileDevice

protocol IInstrumentsServiceGroupDelegate: NSObjectProtocol {
    func receive(response: DTXReceiveObject?)
    
    func sysmontap(sysmotapInfo: IInstrumentsSysmotapInfo, processInfo: IInstrumentsSysmotapProcessesInfo)
    
    func opengl(info: IInstrumentsOpenglInfo)
    
    func networkStatistics(info: [Int64 : IInstrumentsNetworkStatisticsModel])
    
    func energy(info: [Int64 : IInstrumentsEnergyModel])
    
    func deviceNetworking(info: IInstrumentsNetworkingCallback)
    
    func launch(pid: UInt32)
}

extension IInstrumentsServiceGroupDelegate {
    func sysmontap(sysmotapInfo: IInstrumentsSysmotapInfo, processInfo: IInstrumentsSysmotapProcessesInfo) { }
    
    func opengl(info: IInstrumentsOpenglInfo) { }
    
    func networkStatistics(info: [Int64 : IInstrumentsNetworkStatisticsModel]) { }
    
    func energy(info: [Int64 : IInstrumentsEnergyModel]) { }
    
    func deviceNetworking(info: IInstrumentsNetworkingCallback) { }
    
    func launch(pid: UInt32) { }
}

class IInstrumentsServiceGroup: NSObject {
    typealias Service = (IInstrumentsServiceProtocol & IInstrumentsBaseService)

    public lazy var instruments = IInstruments()
    
    public weak var delegate: IInstrumentsServiceGroupDelegate? = nil
    
    private lazy var serviceDic: [IInstrumentsServiceName : any Service] = [:]

    private var timer: Timer? = nil
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

extension IInstrumentsServiceGroup {
    func config(types: [IInstrumentsServiceName]) {
        types.forEach { type in
            config(type)
        }
    }
    
    func config(_ type: IInstrumentsServiceName) {
        if let _ = serviceDic[type] {
            return
        }
        
        addInstance(type: type)
    }
   
    @discardableResult
    func start(_ device: IDevice) -> Bool {
        if instruments.start(device) {
            serviceDic.forEach { item in
                item.value.setup(instruments)
            }
            return true
        }
        return false
    }
    
    @discardableResult
    func restart(_ device: IDevice) -> Bool {
        stop()
        return start(device)
    }
    
    func stop() {
        stopAutoRequest()
        instruments.stop()
    }
    
    /// 此处的request 相当于从 socket通道拿数据
    func request() {
        instruments.receive { [weak self] response in
            self?.delegate?.receive(response: response)
            
            guard let response = response,
                  let name = IInstrumentsServiceName(channel: response.channel),
                  let service = self?.serviceDic[name] else {
                return
            }
            
            service.response(response)
        }
    }
    
    func autoRequest(_ timeInterval: TimeInterval = 0.5) {
        stopAutoRequest()
        
        timer = Timer(timeInterval: timeInterval, repeats: true, block: { [weak self] _ in
            self?.request()
        })
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stopAutoRequest() {
        timer?.invalidate()
        timer = nil
    }
        
    func client<T : Service>(_ type: IInstrumentsServiceName) -> T? {
        return serviceDic[type] as? T
    }
    
    func client<T : Service>(_ block: (T) -> Void) {
        let client = serviceDic.values.first { service in
            if let _ = service as? T {
                return true
            }
            return false
        }
        
        if let client = client as? T {
            block(client)
        }
    }
}

private extension IInstrumentsServiceGroup {
    func addInstance(type: IInstrumentsServiceName) {
        var service: (any Service)? = nil
        
        switch type {
            case .sysmontap:
                let sysmotap = IInstrumentsSysmontap()
                sysmotap.callBack = { [weak self] sysmotapInfo, processInfo in
                    self?.delegate?.sysmontap(sysmotapInfo: sysmotapInfo, processInfo: processInfo)
                }
                service = sysmotap
                
            case .deviceinfo:
                let deviceInfo = IInstrumentsDeviceInfo()
                
                service = deviceInfo
                
            case .opengl:
                let opengl = IInstrumentsOpengl()
                opengl.callBack = { [weak self] openglInfo in
                    self?.delegate?.opengl(info: openglInfo)
                }
                service = opengl
                
            case .processcontrol:
                let processControl = IInstrumentsProcesscontrol()
                processControl.callback = { [weak self] pid in
                    self?.delegate?.launch(pid: pid)
                }
                service = processControl
            
            case .gpu:
                let gpu = IInstrumentsGPU()
                
                service = gpu
            
            case.networkStatistics:
                let networkStatic = IInstrumentsNetworkStatistics()
                networkStatic.callback = { [weak self] response in
                    self?.delegate?.networkStatistics(info: response)
                }
                service = networkStatic
            
            case .networking:
                let networking = IInstrumentsNetworking()
                networking.callback = { [weak self] response in
                    self?.delegate?.deviceNetworking(info: response)
                }
                service = networking
            
            case .energy:
                let energy = IInstrumentsEnergy()
                energy.callback = { [weak self] response in
                    self?.delegate?.energy(info: response)
                }
                service = energy
        }
        
        if let service = service {
            serviceDic[type] = service
        }
    }
}
