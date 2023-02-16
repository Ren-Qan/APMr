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
    func sysmotap(model: IInstrumentsSysmotapModel, arg: IInstrumentRequestArgsProtocol)
    func process(model: IInstrumentsSysmotapProcessesModel, arg: IInstrumentRequestArgsProtocol)
}

class IInstrumentsSysmontap: IInstrumentsBase {
    public weak var delegate: IInstrumentsSysmontapDelegate? = nil
    
    private var sampleInterval: Int = 0
}

extension IInstrumentsSysmontap {
    func start() {
        send(P.start.arg)
    }
    
    func setConfig(sampleInterval: Int = 1000000000) {
        self.sampleInterval = sampleInterval
        send(P.set(sampleInterval: sampleInterval).arg)
    }
}

extension IInstrumentsSysmontap: IInstrumentsServiceProtocol {    
    var server: IInstrumentsServiceName {
        return .sysmontap
    }
    
    func response(_ response: DTXReceiveObject) {
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
            
            if let sysmotap = Mapper<IInstrumentsSysmotapModel>().map(JSON: result[sysI]),
               let process = Mapper<IInstrumentsSysmotapProcessesModel>().map(JSON: result[proI]) {
                let arg = P.set(sampleInterval: sampleInterval).arg
                delegate?.sysmotap(model: sysmotap, arg: arg)
                delegate?.process(model: process, arg: arg)
            }
        }
    }
}

extension IInstrumentsSysmontap {
    enum P {
        case start
        case set(sampleInterval: Int)
        
        var arg: IInstrumentArgs {
            switch self {
                case .start:
                    return IInstrumentArgs(padding: 1, selector: "start")
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
                    return IInstrumentArgs(padding: 2, selector: "setConfig:", dtxArg: args)
            }
        }
    }
    
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
