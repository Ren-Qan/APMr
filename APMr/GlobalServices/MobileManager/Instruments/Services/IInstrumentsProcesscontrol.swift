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
    
    var selector: String {
        switch self {
            case .launch(_):
                return "launchSuspendedProcessWithDevicePath:bundleIdentifier:environment:arguments:options:"
        }
    }
    
    var args: DTXArguments? {
        switch self {
            case .launch(let bundleId):
                let options: [String : Any] = ["StartSuspendedKey" : 0, "KillExisting" : false]
                
                let arg = DTXArguments()
                arg.add("") // devicePath
                arg.add(bundleId) // bundleID
                arg.add([String : Any]()) // environment
                arg.add([]) // arguments
                arg.add(options) // options
                return arg
        }
    }
}
