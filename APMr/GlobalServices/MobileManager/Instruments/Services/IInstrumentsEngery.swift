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
    case start(pid: UInt32)
    
    case sample(pid: UInt32)
    
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
            case .start(let pid):
                let arg = DTXArguments()
                arg.append([pid])
                return arg
            case .sample(let pid):
                let arg = DTXArguments()
                arg.append(Dictionary<String, Any>())
                arg.append([pid])
                return arg
        }
    }
}
