//
//  Networking.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/24.
//

import Foundation
import LibMobileDevice

protocol IInstrumentsNetworkingDelegate: NSObjectProtocol {
    func interfaceDetection(model: IInstruments.Networking.InterfaceDetectionModel)
    
    func connectionDetectedV4(model: IInstruments.Networking.ConnectionDetectedModelV4)
    
    func connectionDetectedV6(model: IInstruments.Networking.ConnectionDetectedModelV6)
    
    func connectionUpdate(model: IInstruments.Networking.ConnectionUpdateModel)
}

extension IInstrumentsNetworkingDelegate {
    func interfaceDetection(model: IInstruments.Networking.InterfaceDetectionModel) { }
    func connectionDetectedV4(model: IInstruments.Networking.ConnectionDetectedModelV4) { }
    func connectionDetectedV6(model: IInstruments.Networking.ConnectionDetectedModelV6) { }
    func connectionUpdate(model: IInstruments.Networking.ConnectionUpdateModel) { }
}

extension IInstruments {
    class Networking: Base {
        public weak var delegate: IInstrumentsNetworkingDelegate? = nil
    }
}

extension IInstruments.Networking {
    func replay() {
        send(P.replay.arg)
    }
    
    func start() {
        send(P.start.arg)
    }
    
    func stop() {
        send(P.stop.arg)
    }
}

extension IInstruments.Networking: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        return .networking
    }
    
    func response(_ response: IInstruments.R) {
        guard let datas = response.object as? [Any],
              datas.count == 2,
              let modelDatas = datas[1] as? [Any],
              let typeNumber = datas[0] as? Int64,
              let type = IInstruments.Networking.MessageType(rawValue: typeNumber) else {
            return
        }
        
        switch type {
            case .interfaceDetection:
                if let model = interfaceDetection(datas: modelDatas) {
                    self.delegate?.interfaceDetection(model: model)
                }
                
            case .connectionDetected:
                if let addData = modelDatas.first as? Data {
                    if addData.count == 16, let model = connectionDetectedV4(datas: modelDatas) {
                        self.delegate?.connectionDetectedV4(model: model)
                    } else if addData.count == 28, let model = connectionDetectedV6(datas: modelDatas) {
                        self.delegate?.connectionDetectedV6(model: model)
                    }
                }
            case .connectionUpdate:
                if let model = connectionUpdate(datas: modelDatas) {
                    self.delegate?.connectionUpdate(model: model)
                }
        }
    }
    
    private func interfaceDetection(datas: [Any]) -> IInstruments.Networking.InterfaceDetectionModel? {
        guard datas.count == 2 else {
            return nil
        }
        var model = IInstruments.Networking.InterfaceDetectionModel()
        model.interfaceIndex = datas[0] as? Int64
        model.name = datas[1] as? String
        return model
    }
    
    private func connectionDetectedV4(datas: [Any]) -> IInstruments.Networking.ConnectionDetectedModelV4? {
        guard datas.count == 8 else {
            return nil
        }
        
        var model = IInstruments.Networking.ConnectionDetectedModelV4()
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

    private func connectionDetectedV6(datas: [Any]) -> IInstruments.Networking.ConnectionDetectedModelV6? {
        guard datas.count == 8 else {
            return nil
        }
                
        var model = IInstruments.Networking.ConnectionDetectedModelV6()
        
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
    
    private func connectionUpdate(datas: [Any]) -> IInstruments.Networking.ConnectionUpdateModel? {
        guard datas.count == 11 else {
            return nil
        }
        var model = IInstruments.Networking.ConnectionUpdateModel()
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

extension IInstruments.Networking {
    enum P {
        case replay
        case start
        case stop
        
        var arg: IInstrumentArgs {
            switch self {
                case .replay: return IInstrumentArgs("replayLastRecordedSession")
                case .start: return IInstrumentArgs("startMonitoring")
                case .stop: return IInstrumentArgs("stopMonitoring")
            }
        }
    }
}
