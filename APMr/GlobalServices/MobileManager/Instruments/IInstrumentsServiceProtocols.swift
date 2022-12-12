//
//  IIntrumentsProtocols.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/28.
//

import Cocoa
import LibMobileDevice

protocol IInstrumentRequestArgsProtocol {
    var selector: String { get }
    
    var args: DTXArguments? { get }
}

enum IInstrumentsServiceName: String, CaseIterable {
    case sysmontap = "com.apple.instruments.server.services.sysmontap"
    
    case opengl = "com.apple.instruments.server.services.graphics.opengl"
    
    case deviceinfo = "com.apple.instruments.server.services.deviceinfo"
    
    case processcontrol = "com.apple.instruments.server.services.processcontrol"
    
    case gpu = "com.apple.instruments.server.services.gpu"
        
    var channel: UInt32 {
        return UInt32(IInstrumentsServiceName.allCases.firstIndex(of: self)! + 10)
    }
    
    var callbackChannel: UInt32 {
        return UINT32_MAX - channel + 1
    }
    
    init?(channel: UInt32) {
        let name = IInstrumentsServiceName.allCases.first { name in
            return name.channel == channel || name.callbackChannel == channel
        }
        if let name = name {
            self = name
        } else {
            return nil
        }
    }
}

protocol IInstrumentsServiceProtocol: NSObjectProtocol {
    associatedtype Arg : IInstrumentRequestArgsProtocol
    
    var server: IInstrumentsServiceName { get }
    
    func response(_ response: DTXReceiveObject?)
    
    // MARK: - optional -
    
    var instrument: IInstruments? { get }
    
    var identifier: UInt32 { get }
    
    var expectsReply: Bool { get }
    
    func start(_ handle: IInstruments?)
    
    func register(_ arg: Arg)
        
    func request()
}

extension IInstrumentsServiceProtocol {
    var instrument: IInstruments? {
        if let service = self as? IInstrumentsBaseService {
            return service.instrumentHandle
        }
        return nil
    }
    
    var identifier: UInt32 {
        guard let service = self as? IInstrumentsBaseService else {
            return 0
        }
        return service.nextIdentifier
    }
    
    var expectsReply: Bool {
        return true
    }
    
    func start(_ handle: IInstruments? = nil) {
        if let handle = handle,
           let service = self as? IInstrumentsBaseService {
            service.instrumentHandle = handle
        }
        instrument?.setup(service: self)
    }
    
    func register(_ arg: Arg) {
        let args = arg.args
        let channel = server.channel
        
        instrument?
            .request(channel: channel,
                     identifier: identifier,
                     selector: arg.selector,
                     args: args,
                     expectsReply: expectsReply)
    }
    
    func request() {
        instrument?.response { [weak self] response in
            if let response = response {
                if let channelID = self?.server.channel,
                   let callbackChannel = self?.server.callbackChannel,
                   (channelID == response.channel || callbackChannel == response.channel) {
                    self?.response(response)
                } else {
                    
                }
               
            }
        }
    }
}
