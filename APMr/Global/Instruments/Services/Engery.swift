//
//  Energy.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/26.
//

import Foundation
import LibMobileDevice
import ObjectMapper

protocol IInstrumentsEnergyDelegate: NSObjectProtocol {
    
}

extension IInstruments {
    class Energy: Base {
        public weak var delegate: IInstrumentsEnergyDelegate? = nil
        
        private var startPids: [PID] = []
        private var sampleAttributes: [String : Any] = [:]
        private var samplePids: [PID] = []
    }
}

extension IInstruments.Energy {
    func start(pids: [PID]) {
        startPids = pids
        send(P.start(pids: pids).arg)
    }
    
    func sample(attributes: [String : Any] = [:], pids: [PID]) {
        sampleAttributes = attributes
        samplePids = pids
        send(P.sample(attributes: attributes, pids: pids).arg)
    }
}

extension IInstruments.Energy: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        return .energy
    }
    
    func response(_ response: IInstruments.R) {
        if let response = response.object as? [Int64 : [String : Any]] {
            var result = [Int64 : Model]()
            let mapper = Mapper<Model>()
            response.forEach { item in
                if let model = mapper.map(JSON: item.value) {
                    result[item.key] = model
                }
            }
        }
    }
}

extension IInstruments.Energy {
    enum P {
        case start(pids: [PID])
        case sample(attributes: [String : Any], pids: [PID])
        
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
