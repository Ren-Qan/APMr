//
//  IInstrumentsNetworking.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/24.
//

import Foundation
import LibMobileDevice

class IInstrumentsNetworking: IInstrumentsBaseService {
    
}

extension IInstrumentsNetworking: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsNetworkingArgs
    
    var server: IInstrumentsServiceName {
        return .networking
    }
    
    func response(_ response: DTXReceiveObject?) {
        
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
