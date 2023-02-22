//
//  IInstrumentsNetworkStatistics.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/24.
//

import Foundation
import LibMobileDevice
import ObjectMapper

protocol IInstrumentsNetworkStatisticsDelegate: NSObjectProtocol {
    func process(modelMap: [UInt32 : IInstrumentsNetworkStatisticsModel], arg: IInstrumentRequestArgsProtocol)
}

class IInstrumentsNetworkStatistics: IInstrumentsBase {
    public weak var delegate: IInstrumentsNetworkStatisticsDelegate? = nil
    
    private var startPids: [UInt32] = []
    private var stopPids: [UInt32] = []
    
    private var sampleConfig: SampleConfig? = nil
}

extension IInstrumentsNetworkStatistics {
    func start(pids: [UInt32]) {
        self.startPids = pids
        send(P.start(pids: pids).arg)
    }
    
    func stop(pids: [UInt32]) {
        self.stopPids = pids
        send(P.stop(pids: pids).arg)
    }
    
    func sample(pids: [UInt32]) {
        let config = SampleConfig.common(pids: pids)
        sample(config: config)
    }
    
    func sample(config: SampleConfig) {
        self.sampleConfig = config
        send(P.sample(config: config).arg)
    }
}

extension IInstrumentsNetworkStatistics: IInstrumentsServiceProtocol {    
    var server: IInstrumentsServiceName {
        return .networkStatistics
    }
    
    func response(_ response: DTXReceiveObject) {
        
        if  let config = self.sampleConfig,
            let response = response.object as? [UInt32 : [String : Any]] {
            var result = [UInt32 : IInstrumentsNetworkStatisticsModel]()
            let mapper = Mapper<IInstrumentsNetworkStatisticsModel>()
            response.forEach { item in
                if let model = mapper.map(JSON: item.value) {
                    result[item.key] = model
                }
            }
            self.delegate?.process(modelMap: result, arg: P.sample(config: config).arg)
        }
    }
}

extension IInstrumentsNetworkStatistics {
    struct SampleConfig {
        var attributes: [String]
        var pids: [UInt32]
        
        static func common(pids: [UInt32]) -> SampleConfig {
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
        case start(pids: [UInt32])
        case stop(pids: [UInt32])
        case sample(config: SampleConfig)
        
        var arg: IInstrumentArgs {
            switch self {
                case .start(let pids):
                    let arg = DTXArguments()
                    arg.append(pids)
                    return IInstrumentArgs(padding: 1, selector: "startSamplingForPIDs:", dtxArg: arg)
                case .stop(let pids):
                    let arg = DTXArguments()
                    arg.append(pids)
                    return IInstrumentArgs(padding: 2, selector: "stopSamplingForPIDs:", dtxArg: arg)
                case .sample(let config):
                    let arg = DTXArguments()
                    arg.append(config.attributes)
                    arg.append(config.pids)
                    return IInstrumentArgs(padding: 3, selector: "sampleAttributes:forPIDs:", dtxArg: arg)
            }
        }
    }
}
