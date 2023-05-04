//
//  IInstrumentsNetworkingModels.swift
//  APMr
//
//  Created by 任玉乾 on 2023/1/3.
//

import Cocoa

extension IInstruments.Networking {
    enum MessageType: Int64 {
        case interfaceDetection = 0
        case connectionDetected = 1
        case connectionUpdate = 2
    }
    
    struct InterfaceDetectionModel {
        var interfaceIndex: Int64?
        var name: String?
    }

    struct ConnectionDetectedModelV4 {
        var local: sockaddr_in?
        var remote: sockaddr_in?
        var interfaceIndex: Int64?
        var pid: Int64?
        var recvBufferSize: Int64?
        var recvBufferUsed: Int64?
        var serialNumber: Int64?
        var netProtocol: NetProtocolV4?
        
        enum NetProtocolV4 {
            case tcp4
            case udp4
        }
    }

    struct ConnectionDetectedModelV6 {
        var local: sockaddr_in6?
        var remote: sockaddr_in6?
        var interfaceIndex: Int64?
        var pid: Int64?
        var recvBufferSize: Int64?
        var recvBufferUsed: Int64?
        var serialNumber: Int64?
        var netProtocol: NetProtocolV6?
        
        enum NetProtocolV6 {
            case tcp6
            case udp6
        }
    }

    struct ConnectionUpdateModel {
        var rxPackets: Int64?
        var rxBytes: Int64?
        var txPackets: Int64?
        var txBytes: Int64?
        var rxDups: Int64?
        var rx000: Int64?
        var txRetx: Int64?
        var minRTT: TimeInterval?
        var avgRTT: TimeInterval?
        var connectionSerial: Int64?
        var time: Int64?
    }

}



