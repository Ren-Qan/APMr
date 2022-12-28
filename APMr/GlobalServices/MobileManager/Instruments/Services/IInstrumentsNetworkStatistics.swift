//
//  IInstrumentsNetworkStatistics.swift
//  APMr
//
//  Created by 任玉乾 on 2022/12/24.
//

import Foundation
import LibMobileDevice
import ObjectMapper

class IInstrumentsNetworkStatistics: IInstrumentsBaseService {
    var callback: (([Int64 : IInstrumentsNetworkStatisticsModel]) -> Void)? = nil
}

extension IInstrumentsNetworkStatistics: IInstrumentsServiceProtocol {
    typealias Arg = IInstrumentsNetworkStatisticsArgs
    
    var server: IInstrumentsServiceName {
        return .networkStatistics
    }
    
    func response(_ response: DTXReceiveObject?) {
        if let response = response?.object as? [Int64 : [String : Any]] {
            var result = [Int64 : IInstrumentsNetworkStatisticsModel]()
            response.forEach { item in
                if let model = Mapper<IInstrumentsNetworkStatisticsModel>().map(JSON: item.value) {
                    result[item.key] = model
                }
            }
            callback?(result)
        }
    }
}

extension Dictionary {

    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .withoutEscapingSlashes)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }

    func printJson() {
        print(json)
    }

}

enum IInstrumentsNetworkStatisticsArgs: IInstrumentRequestArgsProtocol {
    case start(pids: [UInt32])
    
    case stop(pids: [UInt32])
    
    case sample(pids: [UInt32])
    
    var selector: String {
        switch self {
            case .start(_):
                return "startSamplingForPIDs:"
            case .stop(_):
                return "stopSamplingForPIDs:"
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
            case .stop(let pids):
                let arg = DTXArguments()
                arg.append(pids)
                return arg
            case .sample(let pids):
                let arg = DTXArguments()
                arg.append(["net.bytes",
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
                            "net.tx.packets.delta"])
                arg.append(pids)
                return arg
        }
    }
}
