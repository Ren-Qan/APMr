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
        print("Sam [Arr]==== \(response.array)")
        print("Sam [Objc]==== \(response.object)")
    }
}

extension IInstrumentSampling {
    func start() {
        send(P.start.arg)
    }
    
    func stop() {
        send(P.stop.arg)
    }
    
    func samples() {
        send(P.samples.arg)
    }
}

extension IInstrumentSampling {
    
    enum P {
        case start
        case stop
        case samples
        
        var arg: IInstrumentArgs {
            switch self {
                case .samples: return IInstrumentArgs(padding: 1, selector: "samples") // 待测试
                case .start: return IInstrumentArgs(padding: 2, selector: "startSampling")
                case .stop: return IInstrumentArgs(padding: 3, selector: "stopSampling")
            }
        }
    }
}
