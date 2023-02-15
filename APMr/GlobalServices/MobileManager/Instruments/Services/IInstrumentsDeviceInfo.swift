//
//  IInstrumentsRuningProcess.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/29.
//

import Cocoa
import LibMobileDevice

class IInstrumentsDeviceInfo: IInstrumentsBase {
}

extension IInstrumentsDeviceInfo: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsDeviceInfoArgs
    
    
    var server: IInstrumentsServiceName {
        return .deviceinfo
    }

    func response(_ response: DTXReceiveObject?) {

    }
}

enum IInstrumentsDeviceInfoArgs: IInstrumentRequestArgsProtocol {
    
    case runningProcesses
        
    case machTimeInfo
    
    case execname(UInt32)
    
    var selector: String {
        switch self {
            case .runningProcesses:
                return "runningProcesses"
                
            case .machTimeInfo:
                return "machTimeInfo"
                
            case .execname(_):
                return "execnameForPid:"
        }
    }
    
    var dtxArg: DTXArguments? {
        switch self {
            case .execname(let pid):
                let arg = DTXArguments()
                arg.append(pid)
                return arg
            default: return nil
        }
    }
}
