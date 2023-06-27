//
//  NetworkStatistics.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/24.
//

import Foundation
import LibMobileDevice
import ObjectMapper

protocol IInstrumentsNetworkStatisticsDelegate: NSObjectProtocol {
    func process(modelMap: [PID : IInstruments.NetworkStatistics.Model])
}

extension IInstrumentsNetworkStatisticsDelegate {
    func process(modelMap: [PID : IInstruments.NetworkStatistics.Model]) { }
}

extension IInstruments {
    class NetworkStatistics: IInstruments.Base {
        public weak var delegate: IInstrumentsNetworkStatisticsDelegate? = nil
        
        private var startPids: [PID] = []
        private var stopPids: [PID] = []
        
        private var sampleConfig: SampleConfig? = nil
    }
}

extension IInstruments.NetworkStatistics {
    func start(pids: [PID]) {
        self.startPids = pids
        send(P.start(pids: pids).arg)
    }
    
    func stop(pids: [PID]) {
        self.stopPids = pids
        send(P.stop(pids: pids).arg)
    }
    
    func sample(pids: [PID]) {
        let config = SampleConfig.common(pids: pids)
        sample(config: config)
    }
    
    func sample(config: SampleConfig) {
        self.sampleConfig = config
        send(P.sample(config: config).arg)
    }
}

extension IInstruments.NetworkStatistics: IInstrumentsServiceProtocol {
    var server: IInstrumentsServiceName {
        return .networkStatistics
    }
    
    func response(_ response: IInstruments.R) {
        
        if let response = response.object as? [PID : [String : Any]] {
            var result = [PID : Model]()
            let mapper = Mapper<Model>()
            response.forEach { item in
                if let model = mapper.map(JSON: item.value) {
                    result[item.key] = model
                }
            }
            self.delegate?.process(modelMap: result)
        }
    }
}

extension IInstruments.NetworkStatistics {
    struct SampleConfig {
        var attributes: [String]
        var pids: [PID]
        
        static func common(pids: [PID]) -> SampleConfig {
            let att = ["net.bytes",
                       "net.bytes.delta",
                       "net.connections[]",
                       "net.packets",
                       "net.packets.delta",
                       "net.rx.bytes",
                       "net.rx.bytes.delta",
                       "net.rx.packets",
                       "net.rx.packets.delta",
                       "net.tx.bytes",
                       "net.tx.bytes.delta",
                       "net.tx.packets",
                       "net.tx.packets.delta"]
            return SampleConfig(attributes: att, pids: pids)
        }
    }
    
    enum P {
        case start(pids: [PID])
        case stop(pids: [PID])
        case sample(config: SampleConfig)
        
        var arg: IInstrumentArgs {
            switch self {
                case .start(let pids):
                    let arg = DTXArguments()
                    arg.append(pids)
                    return IInstrumentArgs("startSamplingForPIDs:", dtxArg: arg)
                case .stop(let pids):
                    let arg = DTXArguments()
                    arg.append(pids)
                    return IInstrumentArgs("stopSamplingForPIDs:", dtxArg: arg)
                case .sample(let config):
                    let arg = DTXArguments()
                    arg.append(config.attributes)
                    arg.append(config.pids)
                    return IInstrumentArgs("sampleAttributes:forPIDs:", dtxArg: arg)
            }
        }
    }
}
