//
//  IInstrumentsOpengl.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/1.
//

import Cocoa
import LibMobileDevice
import ObjectMapper

class IInstrumentsOpengl: IInstrumentsBaseService {
    public var callBack: ((IInstrumentsOpenglInfo) -> Void)? = nil

}

extension IInstrumentsOpengl: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsOpenglArgs
    
    var server: IInstrumentsServiceName {
        return .opengl
    }

    func response(_ response: DTXReceiveObject?) {
        if let obj = response?.object as? [String : Any],
           let model = Mapper<IInstrumentsOpenglInfo>().map(JSON: obj) {            
           callBack?(model)
        }
    }
}

enum IInstrumentsOpenglArgs: IInstrumentRequestArgsProtocol {
    case startSampling
    
    var selector: String {
        switch self {
            case .startSampling:
                return "startSamplingAtTimeInterval:"
        }
    }
    
    var args: DTXArguments? {
        switch self {
            case .startSampling:
                let arg = DTXArguments()
                arg.appendUInt32Num(0)
                return arg
        }
    }
}
