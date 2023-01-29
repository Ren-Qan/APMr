//
//  IInstrumentsProcesscontrol.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/9.
//

import Cocoa
import LibMobileDevice

class IInstrumentsProcesscontrol: IInstrumentsBaseService {
    var callback: ((UInt32) -> Void)? = nil
}

extension IInstrumentsProcesscontrol: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsProcesscontrolArgs
    
    var server: IInstrumentsServiceName {
        return .processcontrol
    }

    func response(_ response: DTXReceiveObject?) {
        if let pid = response?.object as? UInt32 {
            callback?(pid)
        }
    }
}


enum IInstrumentsProcesscontrolArgs: IInstrumentRequestArgsProtocol {
    case launch(bundleId: String)
    
    case kill(pids: [UInt32])
    
    var selector: String {
        switch self {
            case .launch(_):
                return "launchSuspendedProcessWithDevicePath:bundleIdentifier:environment:arguments:options:"
            
            case .kill(_):
                return "killPid:"
        }
    }
    
    var args: DTXArguments? {
        switch self {
            case .launch(let bundleId):
                let arg = DTXArguments()
                arg.append("") // devicePath
                arg.append(bundleId) // bundleID
                arg.append([String : Any]()) // environment
                arg.append([]) // arguments
                arg.append(["StartSuspendedKey" : 0, "KillExisting" : true]) // options
                return arg
            
            case .kill(let pids):
                let arg = DTXArguments()
                arg.append(pids) // pids
                return arg
        }
    }
}
