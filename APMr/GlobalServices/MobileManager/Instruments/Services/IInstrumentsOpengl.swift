//
//  IInstrumentsOpengl.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/1.
//

import Cocoa
import LibMobileDevice
import ObjectMapper

protocol IInstrumentsOpenglDelegate: NSObjectProtocol {
    func sampling(model: IInstrumentsOpenglModel)
}

class IInstrumentsOpengl: IInstrumentsBase {
    public weak var delegate: IInstrumentsOpenglDelegate? = nil
    
    private var rateSampling: Int = 0
    private var startInterval: Int = 0
}

extension IInstrumentsOpengl {
    func set(rate: Int = 5) {
        self.rateSampling = rate
        send(P.rate(sampling: rate).arg)
    }
    
    func start(interval: Int = 0) {
        self.startInterval = interval
        send(P.start(interval: interval).arg)
    }
}

extension IInstrumentsOpengl: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        return .opengl
    }

    func response(_ response: DTXReceiveObject) {        
        if let obj = response.object as? [String : Any],
           let model = Mapper<IInstrumentsOpenglModel>().map(JSON: obj) {
            self.delegate?.sampling(model: model)
        }
    }
}

extension IInstrumentsOpengl {
    enum P {
        case rate(sampling: Int)
        case start(interval: Int)
        
        var arg: IInstrumentArgs {
            switch self {
                case .rate(let sampling):
                    let dtx = DTXArguments()
                    dtx.append(sampling)
                    return IInstrumentArgs("setSamplingRate:",
                                           dtxArg: dtx)
                case .start(let interval):
                    let dtx = DTXArguments()
                    dtx.append(interval)
                    return IInstrumentArgs("startSamplingAtTimeInterval:",
                                           dtxArg: dtx)
            }
        }
    }
}
