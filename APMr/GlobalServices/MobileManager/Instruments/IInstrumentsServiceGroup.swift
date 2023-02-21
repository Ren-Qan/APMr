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
}

class IInstrumentsServiceGroup {
    public weak var delegate: IInstrumentsServiceGroupDelegate? = nil
    
    public lazy var instruments = IInstruments()
        
    private lazy var serviceDic: [IInstrumentsServiceName : any Service] = [:]
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
    
    /// 此处的request 相当于从 socket通道拿数据
    func receive() {
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
