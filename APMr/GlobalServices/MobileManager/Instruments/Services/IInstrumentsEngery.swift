//
//  IInstrumentsEnergy.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/26.
//

import Foundation
import LibMobileDevice
import ObjectMapper

protocol IInstrumentsEnergyDelegate: NSObjectProtocol {
    
}

class IInstrumentsEnergy: IInstrumentsBase {
    public weak var delegate: IInstrumentsEnergyDelegate? = nil
    
    private var startPids: [UInt32] = []
    
    private var sampleAttributes: [String : Any] = [:]
    private var samplePids: [UInt32] = []
}

extension IInstrumentsEnergy {
    func start(pids: [UInt32]) {
        startPids = pids
        send(P.start(pids: pids).arg)
    }
    
    func sample(attributes: [String : Any] = [:], pids: [UInt32]) {
        sampleAttributes = attributes
        samplePids = pids
        send(P.sample(attributes: attributes, pids: pids).arg)
    }
}

extension IInstrumentsEnergy: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        return .energy
    }
    
    func response(_ response: DTXReceiveObject) {
        if let response = response.object as? [Int64 : [String : Any]] {
            var result = [Int64 : IInstrumentsEnergyModel]()
            let mapper = Mapper<IInstrumentsEnergyModel>()
            response.forEach { item in
                if let model = mapper.map(JSON: item.value) {
                    result[item.key] = model
                }
            }
        }
    }
}

extension IInstrumentsEnergy {
    enum P {
        case start(pids: [UInt32])
        case sample(attributes: [String : Any], pids: [UInt32])
        
        var arg: IInstrumentArgs {
            switch self {
                case .start(let pids):
                    let arg = DTXArguments()
                    arg.append(pids)
                    return IInstrumentArgs("startSamplingForPIDs:",
                                           dtxArg: arg)
                    
                case .sample(let att, let pids):
                    let arg = DTXArguments()
                    arg.append(att)
                    arg.append(pids)
                    return IInstrumentArgs("sampleAttributes:forPIDs:",
                                           dtxArg: arg)
            }
        }
    }
}
