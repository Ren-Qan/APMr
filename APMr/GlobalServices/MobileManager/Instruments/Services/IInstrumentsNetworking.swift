//
//  IInstrumentsNetworking.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/24.
//

import Foundation
import LibMobileDevice

enum IInstrumentsNetworkingCallback {
    case interfaceDetection(IInstrumentsNetworkingInterfaceDetectionModel)
    case connectionDetectedV4(IInstrumentsNetworkingConnectionDetectedModelV4)
    case connectionDetectedV6(IInstrumentsNetworkingConnectionDetectedModelV6)
    case connectionUpdate(IInstrumentsNetworkingConnectionUpdateModel)
}

class IInstrumentsNetworking: IInstrumentsBaseService {
    var callback: ((IInstrumentsNetworkingCallback) -> Void)? = nil
}

extension IInstrumentsNetworking: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsNetworkingArgs
    
    var server: IInstrumentsServiceName {
        return .networking
    }
    
    func response(_ response: DTXReceiveObject?) {
        guard let datas = response?.object as? [Any],
              datas.count == 2,
              let modelDatas = datas[1] as? [Any],
              let typeNumber = datas[0] as? Int64,
              let type = IInstrumentsNetworkingMessageType(rawValue: typeNumber) else {
            return
        }
        
        switch type {
            case .interfaceDetection:
                if let model = interfaceDetection(datas: modelDatas) {
                    callback?(.interfaceDetection(model))
                }
                
            case .connectionDetected:
                if let addData = modelDatas.first as? Data {
                    if addData.count == 16, let model = connectionDetectedV4(datas: modelDatas) {
                        callback?(.connectionDetectedV4(model))
                    } else if addData.count == 28, let model = connectionDetectedV6(datas: modelDatas) {
                        callback?(.connectionDetectedV6(model))
                    }
                }
            case .connectionUpdate:
                if let model = connectionUpdate(datas: modelDatas) {
                    callback?(.connectionUpdate(model))
                }
        }
    }
    
    private func interfaceDetection(datas: [Any]) -> IInstrumentsNetworkingInterfaceDetectionModel? {
        guard datas.count == 2 else {
            return nil
        }
        var model = IInstrumentsNetworkingInterfaceDetectionModel()
        model.interfaceIndex = datas[0] as? Int64
        model.name = datas[1] as? String
        return model
    }
    
    private func connectionDetectedV4(datas: [Any]) -> IInstrumentsNetworkingConnectionDetectedModelV4? {
        guard datas.count == 8 else {
            return nil
        }
        
        var model = IInstrumentsNetworkingConnectionDetectedModelV4()
        if let local = datas[0] as? Data {
            model.local = local.withUnsafeBytes { buffer in
                buffer.load(as: sockaddr_in.self)
            }
        }
        
        if let remote = datas[1] as? Data {
            model.remote = remote.withUnsafeBytes { buffer in
                buffer.load(as: sockaddr_in.self)
            }
        }
        
        model.interfaceIndex = datas[2] as? Int64
        model.pid = datas[3] as? Int64
        model.recvBufferSize = datas[4] as? Int64
        model.recvBufferUsed = datas[5] as? Int64
        model.serialNumber = datas[6] as? Int64
        
        if let type = datas[7] as? Int64 {
            model.netProtocol = type == 1 ? .tcp4 : .udp4
        }
        
        return model
    }

    private func connectionDetectedV6(datas: [Any]) -> IInstrumentsNetworkingConnectionDetectedModelV6? {
        guard datas.count == 8 else {
            return nil
        }
                
        var model = IInstrumentsNetworkingConnectionDetectedModelV6()
        
        if let local = datas[0] as? Data {
            model.local = local.withUnsafeBytes { buffer in
                buffer.load(as: sockaddr_in6.self)
            }
        }
        
        if let remote = datas[1] as? Data {
            model.remote = remote.withUnsafeBytes { buffer in
                buffer.load(as: sockaddr_in6.self)
            }
        }
        
        model.interfaceIndex = datas[2] as? Int64
        model.pid = datas[3] as? Int64
        model.recvBufferSize = datas[4] as? Int64
        model.recvBufferUsed = datas[5] as? Int64
        model.serialNumber = datas[6] as? Int64
        
        if let type = datas[7] as? Int64 {
            model.netProtocol = type == 1 ? .tcp6 : .udp6
        }
        return model
    }
    
    private func connectionUpdate(datas: [Any]) -> IInstrumentsNetworkingConnectionUpdateModel? {
        guard datas.count == 11 else {
            return nil
        }
        var model = IInstrumentsNetworkingConnectionUpdateModel()
        model.rxPackets = datas[0] as? Int64
        model.rxBytes = datas[1] as? Int64
        model.txPackets = datas[2] as? Int64
        model.txBytes = datas[3] as? Int64
        model.rxDups = datas[4] as? Int64
        model.rx000 = datas[5] as? Int64
        model.txRetx = datas[6] as? Int64
        model.minRTT = datas[7] as? TimeInterval
        model.avgRTT = datas[8] as? TimeInterval
        model.connectionSerial = datas[9] as? Int64
        model.time = datas[10] as? Int64
        return model
    }
}

enum IInstrumentsNetworkingArgs: IInstrumentRequestArgsProtocol {
    case replayLastRecordedSession
    
    case startMonitoring
    
    case stopMonitoring
    
    var selector: String {
        switch self {
            case .replayLastRecordedSession:
                return "replayLastRecordedSession"
            case .startMonitoring:
                return "startMonitoring"
            case .stopMonitoring:
                return "stopMonitoring"
        }
    }
    
    var args: DTXArguments? {
        return nil
    }
}
