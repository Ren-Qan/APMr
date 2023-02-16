//
//  IInstrumentsGPU.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/12.
//

import Cocoa
import LibMobileDevice

// FIXME: - 暂时没研究明白怎么用，configure()之后的流程一直走不通，资料较少 查查在补充上去 -

protocol IInstrumentsGPUDelegate: NSObjectProtocol {
    
}

class IInstrumentsGPU: IInstrumentsBase {
    public weak var delegate: IInstrumentsGPUDelegate? = nil
}

extension IInstrumentsGPU {
    
}

extension IInstrumentsGPU: IInstrumentsServiceProtocol {
    
    var server: IInstrumentsServiceName {
        return .gpu
    }
    
    func response(_ response: DTXReceiveObject) {
        
    }
}

extension IInstrumentsGPU {
    struct Configure {
        var counter: Int
        var profile: Int
        var interval: Int
        var limit: Int
        var pid: UInt32
    }
    
    enum P {
        case deviceGPUInfo
        
        case startCollecting
        
        case stopCollecting
        
        case flush
        
        case configure(config: Configure)
        
        var arg: IInstrumentArgs {
            switch self {
                case .deviceGPUInfo: return IInstrumentArgs(padding: 1, selector: "requestDeviceGPUInfo")
                case .startCollecting: return IInstrumentArgs(padding: 2, selector: "startCollectingCounters")
                case .stopCollecting: return IInstrumentArgs(padding: 3, selector: "stopCollectingCounters")
                case .flush: return IInstrumentArgs(padding: 4, selector: "flushRemainingData")
                case .configure(let config):
                    let selector = "configureCounters:counterProfile:interval:windowLimit:tracingPID:"
                    let arg = DTXArguments()
                    arg.append(config.counter)
                    arg.append(config.profile)
                    arg.append(config.interval)
                    arg.append(config.limit)
                    arg.append(config.pid)
                    return IInstrumentArgs(padding: 5, selector: selector, dtxArg: arg)
            }
        }
    }
}
