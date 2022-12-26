//
//  IInstrumentsNetworkStatistics.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/24.
//

import Foundation
import LibMobileDevice

class IInstrumentsNetworkStatistics: IInstrumentsBaseService {
    
}

extension IInstrumentsNetworkStatistics: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsNetworkStatisticsArgs
    
    var server: IInstrumentsServiceName {
        return .networkStatistics
    }
    
    func response(_ response: DTXReceiveObject?) {
        
    }
}


enum IInstrumentsNetworkStatisticsArgs: IInstrumentRequestArgsProtocol {
    case start(pid: UInt32)
    
    case stop(pid: UInt32)
    
    case sample(pid: UInt32)
    
    var selector: String {
        switch self {
            case .start(_):
                return "startSamplingForPIDs:"
            case .stop(_):
                return "stopSamplingForPIDs:"
            case .sample(_):
                return "sampleAttributes:forPIDs:"
        }
    }
    
    var args: DTXArguments? {
        switch self {
            case .start(let pid):
                let arg = DTXArguments()
                arg.append([pid])
                return arg
            case .stop(let pid):
                let arg = DTXArguments()
                arg.append([pid])
                return arg
            case .sample(let pid):
                let arg = DTXArguments()
                arg.append(["net.bytes",
                            "net.bytes.delta",
                            "net.connections[]",
                            "net.packets",
                            "net.packets.delta",
                            "net.rx.bytes",
                            "net.rx.bytes.delta",
                            "net.rx.packets",
                            "net.rx.packets.delta",
                            "net.tx.bytes",
                            "net.tx.bytes.delta",
                            "net.tx.packets",
                            "net.tx.packets.delta"])
                arg.append([pid])
                return arg
        }
    }
}
