//
//  IInstrumentsRuningProcess.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/29.
//

import Cocoa
import LibMobileDevice

protocol IInstrumentsDeviceInfoDelegate: NSObjectProtocol {
    
}

class IInstrumentsDeviceInfo: IInstrumentsBase {
    public weak var delegate: IInstrumentsDeviceInfoDelegate? = nil
    
    private var pid: UInt32 = 0
    private var symbolicatorConfig: SymbolicatorConfig? = nil
}

extension IInstrumentsDeviceInfo {
    func machTime() {
        send(P.machTimeInfo.arg)
    }
    
    func runningProcess() {
        send(P.runningProcesses.arg)
    }
    
    func execname(pid: UInt32) {
        self.pid = pid
        send(P.execname(pid: pid).arg)
    }
    
    func symbolicator(config: SymbolicatorConfig) {
        self.symbolicatorConfig = config
        send(P.symbolicator(config: config).arg)
    }
}

extension IInstrumentsDeviceInfo: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        return .deviceinfo
    }
    
    func response(_ response: DTXReceiveObject) {
        print("[DeviceInfo] --- \(response.object)")
    }
}

extension IInstrumentsDeviceInfo {
    struct SymbolicatorConfig {
        var pid: UInt32
        var selector: String
        
        static func common(pid: UInt32, selector: String = "dyldNotificationReceived:") -> SymbolicatorConfig {
            return SymbolicatorConfig(pid: pid, selector: selector)
        }
    }
    
    enum P {
        case runningProcesses
        
        case machTimeInfo
        
        case execname(pid: UInt32)
        
        case symbolicator(config: SymbolicatorConfig)
        
        var arg: IInstrumentArgs {
            switch self {
                case.machTimeInfo:
                    return IInstrumentArgs(padding: 1, selector: "machTimeInfo")
                case .runningProcesses:
                    return IInstrumentArgs(padding: 2, selector: "runningProcesses")
                case .execname(let pid):
                    let arg = DTXArguments()
                    arg.append(pid)
                    return IInstrumentArgs(padding: 3, selector: "execnameForPid:", dtxArg: arg)
                case .symbolicator(let config):
                    let arg = DTXArguments()
                    arg.append(config.pid)
                    arg.append(config.selector)
                    return IInstrumentArgs(padding: 4, selector: "symbolicatorSignatureForPid:trackingSelector:", dtxArg: arg)
            }
        }
    }
}
