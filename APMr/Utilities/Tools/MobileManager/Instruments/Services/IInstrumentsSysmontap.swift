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
    
    private var timer: Timer? = nil
    
    public func autoRequest() {
        stopAutoRequest()
        
        let timer = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.request()
        }
        
        RunLoop.main.add(timer, forMode: .common)
        timer.fire()
        
        self.timer = timer
    }
    
    public func stopAutoRequest() {
        timer?.invalidate()
        timer = nil
    }
}

extension IInstrumentsSysmontap: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsSysmontapArgs
    
    var server: IInstrumentsServiceName {
        return .sysmontap
    }
    
    func response(_ response: DTXReceiveObject?) {
        if let result = response?.object as? [[String : Any]], result.count >= 2 {
           if let sysmotapInfo = Mapper<IInstrumentsSysmotapInfo>().map(JSON: result[0]),
              let processInfo = Mapper<IInstrumentsSysmotapProcessesInfo>().map(JSON: result[1]) {
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
                "procAttrs": [
                    "memVirtualSize", "cpuUsage", "ctxSwitch", "intWakeups", "physFootprint", "memResidentSize", "memAnon", "pid", "name"
                ],
                "sysAttrs": [
                    "vmExtPageCount", "vmFreeCount", "vmPurgeableCount", "vmSpeculativeCount", "physMemSize"
                ]
            ]
            let args = DTXArguments()
            args.add(config)
            return args
        }
        return nil
    }
}
