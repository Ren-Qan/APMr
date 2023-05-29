//
//  ObjectAlloc.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//

import Foundation
import LibMobileDevice

protocol IInstrumentsObjectAllocDelegate: NSObjectProtocol {
    func prepared(response: [String : Any])
}

extension IInstrumentsObjectAllocDelegate {
    func prepared(response: [String : Any]) { }
}

extension IInstruments {
    class ObjectAlloc: Base {
        public weak var delegate: IInstrumentsObjectAllocDelegate? = nil
        
        private var config: ParpareConfig? = nil
        private var pid: PID = 0
    }
}

extension IInstruments.ObjectAlloc {
    func parpare(config: ParpareConfig = .default) {
        self.config = config
        send(P.parpare(config: config).arg)
    }
    
    func collection(pid: PID) {
        self.pid = pid
        send(P.collection(pid: pid).arg)
    }
    
    func stop() {
        send(P.stop.arg)
    }
}

extension IInstruments.ObjectAlloc: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        return .objectalloc
    }
    
    func response(_ response: IInstruments.R) {
        if let response = response.object as? [String : Any]  {
            self.delegate?.prepared(response: response)
        }
    }
}

extension IInstruments.ObjectAlloc {
    struct ParpareConfig {
        var launch: [String : Any]
        var mask: Int
        
        static var `default`: ParpareConfig {
            return .init(launch: [:], mask: 1335693056)
        }
    }
    
    enum P {
        case parpare(config: ParpareConfig)
        case collection(pid: PID)
        case stop
        
        var arg: IInstrumentArgs {
            switch self {
                case .parpare(let config):
                    let selector = "preparedEnvironmentForLaunch:eventsMask:"
                    let arg = DTXArguments()
                    arg.append(config.launch)
                    arg.append(config.mask)
                    return IInstrumentArgs(selector, dtxArg: arg)
                    
                case .collection(let pid):
                    let arg = DTXArguments()
                    arg.append(pid)
                    return IInstrumentArgs("startCollectionWithPid:", dtxArg: arg)
                    
                case .stop: return IInstrumentArgs("stopCollection")
            }
        }
    }
}
