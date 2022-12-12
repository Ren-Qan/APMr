//
//  IInstrumentsRuningProcess.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/29.
//

import Cocoa
import LibMobileDevice

class IInstrumentsDeviceInfo: IInstrumentsBaseService {

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
    
    var selector: String {
        switch self {
            case .runningProcesses:
                return "runningProcesses"
                
            case .machTimeInfo:
                return "machTimeInfo"
        }
    }
    
    var args: DTXArguments? {
        return nil
    }
}
