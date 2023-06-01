//
//  RuningProcess.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/29.
//

import Cocoa
import LibMobileDevice

protocol IInstrumentsDeviceInfoDelegate: NSObjectProtocol {
    func trace(codes: [TraceID : String])
    
    func machTime(info: IInstruments.DeviceInfo.MT)
    
    func running(process: [IInstruments.DeviceInfo.Process])
}

extension IInstrumentsDeviceInfoDelegate {
    func trace(codes: [TraceID : String]) { }
    func machTime(info: IInstruments.DeviceInfo.MT) { }
    func running(process: [[String : Any]]) { }
}

extension IInstruments {
    class DeviceInfo: Base {
        public weak var delegate: IInstrumentsDeviceInfoDelegate? = nil
        
        private var pid: PID = 0
        private var symbolicatorConfig: SymbolicatorConfig? = nil
    }
}

extension IInstruments.DeviceInfo {
    func machTime() {
        send(P.machTimeInfo.arg)
    }
    
    func traceCodes() {
        send(P.traceCodesFile.arg)
    }
    
    func runningProcess() {
        send(P.runningProcesses.arg)
    }
    
    func execname(pid: PID) {
        self.pid = pid
        send(P.execname(pid: pid).arg)
    }
    
    func symbolicator(config: SymbolicatorConfig) {
        self.symbolicatorConfig = config
        send(P.symbolicator(config: config).arg)
    }
}

extension IInstruments.DeviceInfo: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        return .deviceinfo
    }
    
    func response(_ response: IInstruments.R) {
        if let runningProcess = response.object as? [[String : Any]] {
            let processes = runningProcess.compactMap { map in
                if let name = map["name"] as? String,
                   let pid = map["pid"] as? PID,
                   let bundleId = map["bundleIdentifier"] as? String {
                    return IInstruments.DeviceInfo.Process(name: name,
                                                           pid: pid,
                                                           bundleId: bundleId)
                }
                return nil
            }
            self.delegate?.running(process: processes)
        } else if let arr = response.object as? [Any], arr.count >= 3 {
            if let mt = arr[0] as? Int64,
               let mn = arr[1] as? Int64,
               let md = arr[2] as? Int64 {
                let MT = MT(mach_absolute_time: mt,
                            mach_timebase_number: mn,
                            mach_timebase_denom: md,
                            usecs_since_epoch: Date().timeIntervalSince1970 * 1000000)
                self.delegate?.machTime(info: MT)
            }
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

extension IInstruments.DeviceInfo {
    struct SymbolicatorConfig {
        var pid: PID
        var selector: String
        
        static func common(pid: PID, selector: String = "dyldNotificationReceived:") -> SymbolicatorConfig {
            return SymbolicatorConfig(pid: pid, selector: selector)
        }
    }
    
    enum P {
        case runningProcesses
        
        case machTimeInfo
        
        case traceCodesFile
        
        case execname(pid: PID)
        
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
