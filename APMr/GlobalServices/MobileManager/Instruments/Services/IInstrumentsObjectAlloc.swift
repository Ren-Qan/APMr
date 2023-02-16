//
//  IInstrumentsObjectAlloc.swift
//  APMr
//
//  Created by 任玉乾 on 2023/2/15.
//

import Foundation
import LibMobileDevice

protocol IInstrumentsObjectAllocDelegate: NSObjectProtocol {
    func prepared(response: [String : Any], arg: IInstrumentRequestArgsProtocol)
}

class IInstrumentsObjectAlloc: IInstrumentsBase {
    public weak var delegate: IInstrumentsObjectAllocDelegate? = nil
    
    private var config: ParpareConfig? = nil
    private var pid: UInt32 = 0
}

extension IInstrumentsObjectAlloc {
    func parpare(config: ParpareConfig = .default) {
        self.config = config
        send(P.parpare(config: config).arg)
    }
    
    func collection(pid: UInt32) {
        self.pid = pid
        send(P.collection(pid: pid).arg)
    }
    
    func stop() {
        send(P.stop.arg)
    }
}

extension IInstrumentsObjectAlloc: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        return .objectalloc
    }
    
    func response(_ response: DTXReceiveObject) {
        if let config = self.config,
           response.identifier == P.parpare(config: config).arg.identifier {
            if let response = response.object as? [String : Any]  {
                self.delegate?.prepared(response: response, arg: P.parpare(config: config).arg)
            }
        }
    }
}

extension IInstrumentsObjectAlloc {
    struct ParpareConfig {
        var launch: [String : Any]
        var mask: Int
        
        static var `default`: ParpareConfig {
            return .init(launch: [:], mask: 1335693056)
        }
    }
    
    enum P {
        case parpare(config: ParpareConfig)
        case collection(pid: UInt32)
        case stop
        
        var arg: IInstrumentArgs {
            switch self {
                case .parpare(let config):
                    let selector = "preparedEnvironmentForLaunch:eventsMask:"
                    let arg = DTXArguments()
                    arg.append(config.launch)
                    arg.append(config.mask)
                    return IInstrumentArgs(padding: 1, selector: selector, dtxArg: arg)
                    
                case .collection(let pid):
                    let arg = DTXArguments()
                    arg.append(pid)
                    return IInstrumentArgs(padding: 2, selector: "startCollectionWithPid:", dtxArg: arg)
                    
                case .stop: return IInstrumentArgs(padding: 3, selector: "stopCollection")
            }
        }
    }
}
