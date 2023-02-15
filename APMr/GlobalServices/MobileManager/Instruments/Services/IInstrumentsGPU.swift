//
//  IInstrumentsGPU.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/12.
//

import Cocoa
import LibMobileDevice

// FIXME: - 暂时没研究明白怎么用，configure()之后的流程一直走不通，资料较少 查查在补充上去 -

class IInstrumentsGPU: IInstrumentsBase {
    
}

extension IInstrumentsGPU: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsGPUArgs
    
    var server: IInstrumentsServiceName {
        return .gpu
    }
    
    func response(_ response: DTXReceiveObject?) {
        
    }
}

enum IInstrumentsGPUArgs: IInstrumentRequestArgsProtocol {
    case requestDeviceGPUInfo
    
    case configure(pid: UInt32)
    
    case startCollectingCounters
    
    case stopCollectingCounters
    
    case flushRemainingData
    
    var selector: String {
        switch self {
            case .requestDeviceGPUInfo:
                return "requestDeviceGPUInfo"
            case .configure(_):
                return "configureCounters:counterProfile:interval:windowLimit:tracingPID:"
            case .startCollectingCounters:
                return "startCollectingCounters"
            case .stopCollectingCounters:
                return "stopCollectingCounters"
            case .flushRemainingData:
                return "flushRemainingData"
        }
    }
    
    var dtxArg: DTXArguments? {
        switch self {
            case .configure(let pid):
                let arg = DTXArguments()
                arg.appendInt64Num(0) // counters
                arg.appendInt64Num(3) // counterProfile
                arg.appendInt64Num(0) // interval
                arg.appendInt64Num(0) // windowLimit
                arg.appendUInt32Num(pid) // tracingPID
                return arg
            default:
                return nil
        }
    }
}
