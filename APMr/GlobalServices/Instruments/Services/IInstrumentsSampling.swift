//
//  IInstrumentsSampling.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/16.
//

import Foundation
import LibMobileDevice

protocol IInstrumentSamplingDelegate: NSObjectProtocol {
    
}
//TODO: - 补充 Sampling Selector
class IInstrumentSampling: IInstrumentsBase {
    public weak var delegagte: IInstrumentSamplingDelegate? = nil
}

extension IInstrumentSampling: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        .sampling
    }
    
    func response(_ response: DTXReceiveObject) {
        
    }
}

extension IInstrumentSampling {
    func start() {
        send(P.start.arg)
    }
    
    func stop() {
        send(P.stop.arg)
    }
}

extension IInstrumentSampling {
    
    enum P {
        case start
        case stop
        
        var arg: IInstrumentArgs {
            switch self {
                case .start: return IInstrumentArgs("startSampling")
                case .stop: return IInstrumentArgs("stopSampling")
            }
        }
    }
}
