//
//  IInstrumentsEnergy.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/26.
//

import Foundation
import LibMobileDevice
import ObjectMapper

class IInstrumentsEnergy: IInstrumentsBaseService {
    var callback: (([Int64 : IInstrumentsEnergyModel]) -> Void)? = nil
}

extension IInstrumentsEnergy: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsEnergyArgs
    
    var server: IInstrumentsServiceName {
        return .energy
    }
    
    func response(_ response: DTXReceiveObject?) {
        if let response = response?.object as? [Int64 : [String : Any]] {
            var result = [Int64 : IInstrumentsEnergyModel]()
            let mapper = Mapper<IInstrumentsEnergyModel>()
            response.forEach { item in
                if let model = mapper.map(JSON: item.value) {
                    result[item.key] = model
                }
            }
            callback?(result)
        }
    }
}

enum IInstrumentsEnergyArgs: IInstrumentRequestArgsProtocol {
    case start(pids: [UInt32])
    
    case sample(pids: [UInt32])
    
    var selector: String {
        switch self {
            case .start(_):
                return "startSamplingForPIDs:"
            case .sample(_):
                return "sampleAttributes:forPIDs:"
        }
    }
    
    var args: DTXArguments? {
        switch self {
            case .start(let pids):
                let arg = DTXArguments()
                arg.append(pids)
                return arg
            case .sample(let pids):
                let arg = DTXArguments()
                arg.append(Dictionary<String, Any>())
                arg.append(pids)
                return arg
        }
    }
}
