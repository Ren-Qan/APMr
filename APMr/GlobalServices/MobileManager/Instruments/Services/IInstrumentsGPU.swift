//
//  IInstrumentsGPU.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/12.
//

import Cocoa
import LibMobileDevice

import SwiftyJSON

class IInstrumentsGPU: IInstrumentsBaseService {

}

extension IInstrumentsGPU: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsGPUArgs
    
    var server: IInstrumentsServiceName {
        return .gpu
    }

    func response(_ response: DTXReceiveObject?) {
        print("\(response?.identifier)")
        if let object = response?.object {
            print(object)
        }
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
    
    var args: DTXArguments? {
        switch self {
            case .configure(let pid):
                let arg = DTXArguments()
                arg.appendInt64Num(0) // counters
                arg.appendInt64Num(0) // counterProfile
                arg.appendInt64Num(0) // interval
                arg.appendInt64Num(0) // windowLimit
                arg.appendUInt32Num(pid) // tracingPID
                return arg
            default:
                return nil
        }
    }
}
