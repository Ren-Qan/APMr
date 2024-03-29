//
//  GPU.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/12.
//

import Cocoa
import LibMobileDevice

// FIXME: - 暂时没研究明白怎么用，configure()之后的流程一直走不通，资料较少 查查在补充上去 -

protocol IInstrumentsGPUDelegate: NSObjectProtocol {
    
}

extension IInstruments {
    class GPU: Base {
        public weak var delegate: IInstrumentsGPUDelegate? = nil
    }
}

extension IInstruments.GPU: IInstrumentsServiceProtocol {
    
    var server: IInstrumentsServiceName {
        return .gpu
    }
    
    func response(_ response: IInstruments.R) {
        
    }
}

extension IInstruments.GPU {
    struct Configure {
        var counter: Int
        var profile: Int
        var interval: Int
        var limit: Int
        var pid: PID
    }
    
    enum P {
        case deviceGPUInfo
        
        case startCollecting
        
        case stopCollecting
        
        case flush
        
        case configure(config: Configure)
        
        var arg: IInstrumentArgs {
            switch self {
                case .deviceGPUInfo: return IInstrumentArgs("requestDeviceGPUInfo")
                case .startCollecting: return IInstrumentArgs("startCollectingCounters")
                case .stopCollecting: return IInstrumentArgs("stopCollectingCounters")
                case .flush: return IInstrumentArgs("flushRemainingData")
                case .configure(let config):
                    let selector = "configureCounters:counterProfile:interval:windowLimit:tracingPID:"
                    let arg = DTXArguments()
                    arg.append(config.counter)
                    arg.append(config.profile)
                    arg.append(config.interval)
                    arg.append(config.limit)
                    arg.append(config.pid)
                    return IInstrumentArgs(selector, dtxArg: arg)
            }
        }
    }
}
