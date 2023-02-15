//
//  IInstrumentsObjectAlloc.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//

import Foundation
import LibMobileDevice

class IInstrumentsObjectAlloc: IInstrumentsBase {
    let a = ""
}

extension IInstrumentsObjectAlloc: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsObjectAllocArgs
    
    
    
    var server: IInstrumentsServiceName {
        return .objectalloc
    }
    
    func response(_ response: DTXReceiveObject?) {
        
    }
}


enum IInstrumentsObjectAllocArgs: IInstrumentRequestArgsProtocol {
    case parpareForLaunch
    
    case collection(pid: UInt32)
    
    case stopCollection
    
    var selector: String {
        switch self {
            case .parpareForLaunch:
                return "preparedEnvironmentForLaunch:eventsMask:"
            case .collection(_):
                return "startCollectionWithPid:"
            case .stopCollection:
                return "stopCollection"
        }
    }
    
    var dtxArg: DTXArguments? {
        switch self {
            case .parpareForLaunch:
                let arg = DTXArguments()
                arg.append([:])
                arg.append(1335693056)
                return arg
                
            case .collection(let pid):
                let arg = DTXArguments()
                arg.appendUInt32Num(pid)
                return arg
                
            default: return nil
        }
    }
}
