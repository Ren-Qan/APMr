//
//  IInstrumentsServiceGroup.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/8.
//

import Cocoa
import LibMobileDevice

class IInstrumentsServiceGroup: NSObject {
    private lazy var instruments = IInstruments.share
    
    public typealias Service = IInstrumentsServiceProtocol
    
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
    public var fd: Int32? {
        return instruments.fd
    }
    
    public var isConnected: Bool {
        return instruments.isConnected
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
        stop()
        instruments.delegate = self
        if instruments.start(device) {
            serviceDic.forEach { item in
                item.value.setup(instruments)
            }
            return true
        }
        return false
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
