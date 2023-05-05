//
//  IInstrumentsServiceGroup.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/8.
//

import Cocoa
import LibMobileDevice

class IInstrumentsServiceGroup: NSObject {
    private lazy var instruments: IInstruments = {
        let instruments = IInstruments()
        instruments.delegate = self
        return instruments
    }()
        
    private lazy var serviceDic: [IInstrumentsServiceName : any Service] = [:]
}

extension IInstrumentsServiceGroup: IInstrumentsDelegate {
    func received(responsed: IInstruments.R?) {
        guard let response = responsed,
              let name = IInstrumentsServiceName(channel: response.channel),
              let service = serviceDic[name] else {
            return
        }
        service.response(response)
    }
}

extension IInstrumentsServiceGroup {
    typealias Service = IInstrumentsServiceProtocol
}

extension IInstrumentsServiceGroup {
    public var fd: Int32? {
        return instruments.fd
    }
    
    func config(_ clients: [Service]) {
        clients.forEach { client in
            config(client)
        }
    }
    
    func config(_ client: Service) {
        serviceDic[client.server] = client
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
        instruments.stop()
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
