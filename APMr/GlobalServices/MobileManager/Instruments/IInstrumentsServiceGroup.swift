//
//  IInstrumentsServiceGroup.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/8.
//

import Cocoa

protocol IInstrumentsServiceGroupDelegate: NSObjectProtocol {
    func sysmontap(sysmotapInfo: IInstrumentsSysmotapInfo, processInfo: IInstrumentsSysmotapProcessesInfo)
    
    func opengl(info: IInstrumentsOpenglInfo)
    
    func launch(pid: UInt32)
}

extension IInstrumentsServiceGroupDelegate {
    func sysmontap(sysmotapInfo: IInstrumentsSysmotapInfo, processInfo: IInstrumentsSysmotapProcessesInfo) {
        
    }
    
    func opengl(info: IInstrumentsOpenglInfo) {
        
    }
    
    func launch(pid: UInt32) {
        
    }
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
                item.value.start(instruments)
            }
            return true
        }
        return false
    }
    
    func autoRequest(_ timeInterval: TimeInterval = 0.5) {
        stopRequest()
        
        timer = Timer(timeInterval: 0.5, repeats: true, block: { [weak self] _ in
            self?.request()
        })
        
        timer?.fire()
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stopRequest() {
        timer?.invalidate()
        timer = nil
    }
    
    func client<T : Service>(_ type: IInstrumentsServiceName) -> T? {
        return serviceDic[type] as? T
    }
}

private extension IInstrumentsServiceGroup {
    func request() {
        instruments.response { [weak self] response in
            guard let response = response,
                  let name = IInstrumentsServiceName(channel: response.channel),
                  let service = self?.serviceDic[name] else {
                return
            }
            
            service.response(response)
        }
    }
    
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
        }
        
        if let service = service {
            serviceDic[type] = service
        }
    }
}
