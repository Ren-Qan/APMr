//
//  IInstrumentsEngery.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/26.
//

import Foundation
import LibMobileDevice

class IInstrumentsEngery: IInstrumentsBaseService {
    
}

extension IInstrumentsEngery: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsEngeryArgs
    
    var server: IInstrumentsServiceName {
        return .engery
    }
    
    func response(_ response: DTXReceiveObject?) {
        
    }
}


enum IInstrumentsEngeryArgs: IInstrumentRequestArgsProtocol {
    case start(pids: [UInt32])
    
    case sample(pids: [UInt32])
    
    var selector: String {
        switch self {
            case .start(_):
                return "startSamplingForPIDs:"
            case .sample(_):
                return "sampleAttributes:forPIDs:"
        }
    }
    
    var args: DTXArguments? {
        switch self {
            case .start(let pids):
                let arg = DTXArguments()
                arg.append(pids)
                return arg
            case .sample(let pids):
                let arg = DTXArguments()
                arg.append(Dictionary<String, Any>())
                arg.append(pids)
                return arg
        }
    }
}
