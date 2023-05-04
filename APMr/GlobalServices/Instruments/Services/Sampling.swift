//
//  Sampling.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/16.
//

import Foundation
import LibMobileDevice

protocol IInstrumentSamplingDelegate: NSObjectProtocol {
    
}

extension IInstruments {
    //TODO: - 补充 Sampling Selector
    class Sampling: Base {
        public weak var delegagte: IInstrumentSamplingDelegate? = nil
    }
}

extension IInstruments.Sampling: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        .sampling
    }
    
    func response(_ response: DTXReceiveObject) {
        
    }
}

extension IInstruments.Sampling {
    func start() {
        send(P.start.arg)
    }
    
    func stop() {
        send(P.stop.arg)
    }
}

extension IInstruments.Sampling {
    
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
