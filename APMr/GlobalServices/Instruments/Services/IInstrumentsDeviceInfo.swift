//
//  IInstrumentsRuningProcess.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/29.
//

import Cocoa
import LibMobileDevice

protocol IInstrumentsDeviceInfoDelegate: NSObjectProtocol {
    func trace(codes: [Int64 : String])
    
    func machTime(info: [Any])
    
    func running(process: [[String : Any]])
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
    
    func traceCodes() {
        send(P.traceCodesFile.arg)
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
        if let runningProcess = response.object as? [[String : Any]] {
            self.delegate?.running(process: runningProcess)
        } else if let arr = response.object as? [Any]  {
            delegate?.machTime(info: arr)
        } else if let codes = response.object as? String {
            let result = codes.split(separator: "\n").reduce(into: [Int64: String]()) { (dict, line) in
                let parts = line.split(separator: "\t")
                if parts.count == 2 {
                    let scanner = Scanner(string: String(parts[0]))
                    var keyValue: Int64 = 0
                    scanner.scanHexInt64(&keyValue)
                    dict[keyValue] = String(parts[1])
                }
            }
            delegate?.trace(codes: result)
        }
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
        
        case traceCodesFile
        
        case execname(pid: UInt32)
        
        case symbolicator(config: SymbolicatorConfig)
        
        var arg: IInstrumentArgs {
            switch self {
                case.machTimeInfo:
                    return IInstrumentArgs("machTimeInfo")
                    
                case .traceCodesFile:
                    return IInstrumentArgs("traceCodesFile")
                    
                case .runningProcesses:
                    return IInstrumentArgs("runningProcesses")
                case .execname(let pid):
                    let arg = DTXArguments()
                    arg.append(pid)
                    return IInstrumentArgs("execnameForPid:", dtxArg: arg)
                case .symbolicator(let config):
                    let arg = DTXArguments()
                    arg.append(config.pid)
                    arg.append(config.selector)
                    return IInstrumentArgs("symbolicatorSignatureForPid:trackingSelector:", dtxArg: arg)
            }
        }
    }
}