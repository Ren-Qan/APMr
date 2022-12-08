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
}

extension IInstrumentsServiceGroupDelegate {
    func sysmontap(sysmotapInfo: IInstrumentsSysmotapInfo, processInfo: IInstrumentsSysmotapProcessesInfo) {
        
    }
    
    func opengl(info: IInstrumentsOpenglInfo) {
        
    }
}

class IInstrumentsServiceGroup: NSObject {
    fileprivate typealias Service = (IInstrumentsServiceProtocol & IInstrumentsBaseService)
        
    private lazy var serviceDic: [IInstrumentsServiceName : any Service] = [:]
    
    private lazy var instruments = IInstruments()
    
    private var timer: Timer? = nil
    
    public weak var delegate: IInstrumentsServiceGroupDelegate? = nil
    
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
    
    func start(_ device: IDevice) -> Bool {
        if instruments.start(device) {
            serviceDic.forEach { item in
                item.value.start(instruments)
                item.value.defaultRegister()
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
                
                break
            case .opengl:
                let opengl = IInstrumentsOpengl()
                opengl.callBack = { [weak self] openglInfo in
                    self?.delegate?.opengl(info: openglInfo)
                }
                service = opengl
                break
        }
        
        if let service = service {
            serviceDic[type] = service
        }
    }
}
