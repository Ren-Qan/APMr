//
//  IInstrumentsCPU.swift
//  TestAPP
//
//  Created by 任玉乾 on 2022/11/28.
//

import Cocoa
import LibMobileDevice
import ObjectMapper

protocol IInstrumentsSysmontapDelegate: NSObjectProtocol {
    func sysmotap(info: IInstrumentsSysmotapInfo, arg: IInstrumentsSysmontap.A)
    func process(info: IInstrumentsSysmotapProcessesInfo, arg: IInstrumentsSysmontap.A)
}

class IInstrumentsSysmontap: IInstrumentsBase {
    public weak var delegate: IInstrumentsSysmontapDelegate? = nil
    
    private var sampleInterval: Int = 0
}

extension IInstrumentsSysmontap {
    enum P {
        case start
        case set(sampleInterval: Int)
        
        var arg: A {
            switch self {
            case .start:
                return A(.max - 1, "start")
            case .set(let sampleInterval):
                let config: [String : Any] = [
                    "bm": 0,
                    "ur": 1000,
                    "cpuUsage": true,
                    "sampleInterval": sampleInterval,
                    "sysAttrs": IInstrumentsSysmontap.sysAttrs,
                    "procAttrs": IInstrumentsSysmontap.procAttrs,
                ]
                
                let args = DTXArguments()
                args.append(config)
                return A(.max - 2, "setConfig:", args)
            }
        }
    }
    
    func start() {
        send(P.start.arg)
    }
    
    func setConfig(sampleInterval: Int = 1000000000) {
        self.sampleInterval = sampleInterval
        send(P.set(sampleInterval: sampleInterval).arg)
    }
}

extension IInstrumentsSysmontap: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsSysmontap.A
    
    var server: IInstrumentsServiceName {
        return .sysmontap
    }
    
    func response(_ response: DTXReceiveObject) {
        if response.identifier == P.start.arg.identifier {
            return
        }
        
        if let result = response.object as? [[String : Any]], result.count >= 2 {
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
                let arg = P.set(sampleInterval: sampleInterval).arg
                delegate?.sysmotap(info: sysmotapInfo, arg: arg)
                delegate?.process(info: processInfo, arg: arg)
            }
        }
    }
}

extension IInstrumentsSysmontap {
    struct A: IInstrumentRequestArgsProtocol {
        var identifier: UInt32
        var selector: String
        var dtxArg: DTXArguments? = nil
        
        init( _ identifier: UInt32,
              _ selector: String,
              _ dtxArg: DTXArguments? = nil) {
            
            self.identifier = identifier
            self.selector = selector
            self.dtxArg = dtxArg
        }
    }
}

extension IInstrumentsSysmontap {
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
