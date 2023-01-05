//
//  IInstrumentsCPU.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/28.
//

import Cocoa
import LibMobileDevice
import ObjectMapper

class IInstrumentsSysmontap: IInstrumentsBaseService  {
    public var callBack: ((IInstrumentsSysmotapInfo, IInstrumentsSysmotapProcessesInfo) -> Void)? = nil
    
    public static let procAttrs = [
        "cpuUsage",
        "ctxSwitch",
        "intWakeups",
        "physFootprint",
        "memVirtualSize",
        "memResidentSize",
        "memAnon",
        "pid",
        "name",
        "diskBytesWritten",
        "diskBytesRead"
    ]
    
    public static let sysAttrs = [
        "vmExtPageCount",
        "vmFreeCount",
        "vmPurgeableCount",
        "vmSpeculativeCount",
        "physMemSize"
    ]
}

extension IInstrumentsSysmontap: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsSysmontapArgs
    
    var server: IInstrumentsServiceName {
        return .sysmontap
    }
    
    func response(_ response: DTXReceiveObject?) {
        if let result = response?.object as? [[String : Any]], result.count >= 2 {
            var sysI = 0
            var proI = 1
            
            for (index, item) in result.enumerated() {
                if let _ = item["Processes"] {
                    proI = index
                    sysI = 1 - proI
                    break
                }
            }
            
            if let sysmotapInfo = Mapper<IInstrumentsSysmotapInfo>().map(JSON: result[sysI]),
               let processInfo = Mapper<IInstrumentsSysmotapProcessesInfo>().map(JSON: result[proI]) {
                callBack?(sysmotapInfo, processInfo)
            }
        }
    }
}

enum IInstrumentsSysmontapArgs: IInstrumentRequestArgsProtocol {
    case setConfig
    
    case start
    
    var selector: String {
        switch self {
            case .setConfig:
                return "setConfig:"
            case .start:
                return "start"
        }
    }
    
    var args: DTXArguments? {
        if self == .setConfig {
            let config: [String : Any] = [
                "bm": 0,
                "cpuUsage": true,
                "ur": 1000,
                "sampleInterval": 1000000000,
                "procAttrs": IInstrumentsSysmontap.procAttrs,
                "sysAttrs": IInstrumentsSysmontap.sysAttrs,
            ]
            let args = DTXArguments()
            args.append(config)
            return args
        }
        return nil
    }
}

//'procAttrs': ['memVirtualSize', 'cpuUsage', 'procStatus', 'appSleep', 'uid', 'vmPageIns', 'memRShrd',
//              'ctxSwitch', 'memCompressed', 'intWakeups', 'cpuTotalSystem', 'responsiblePID', 'physFootprint',
//              'cpuTotalUser', 'sysCallsUnix', 'memResidentSize', 'sysCallsMach', 'memPurgeable',
//              'diskBytesRead', 'machPortCount', '__suddenTerm', '__arch', 'memRPrvt', 'msgSent', 'ppid',
//              'threadCount', 'memAnon', 'diskBytesWritten', 'pgid', 'faults', 'msgRecv', '__restricted', 'pid',
//              '__sandbox']

//'sysAttrs': ['diskWriteOps', 'diskBytesRead', 'diskBytesWritten', 'threadCount', 'vmCompressorPageCount',
//             'vmExtPageCount', 'vmFreeCount', 'vmIntPageCount', 'vmPurgeableCount', 'netPacketsIn',
//             'vmWireCount', 'netBytesIn', 'netPacketsOut', 'diskReadOps', 'vmUsedCount', '__vmSwapUsage',
//             'netBytesOut']
